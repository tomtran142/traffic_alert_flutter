import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/engine/alert_engine.dart';
import '../../core/engine/geo_utils.dart';
import '../../core/audio/alert_audio_engine.dart';
import '../../data/binary/binary_alert_repository.dart';
import '../../data/tasco/tasco_map_engine.dart';
import '../../domain/model/models.dart';

class AlertServiceHandler {
  final AlertEngine alertEngine;
  final AlertAudioEngine audioEngine;
  final BinaryAlertRepository alertRepository;
  final TascoMapEngine tascoMapEngine;
  AlertSettings settings;

  final void Function(UserState) onUserStateChanged;
  final void Function(List<ActiveAlert>) onActiveAlertsChanged;
  final void Function(CurrentSpeedLimit) onSpeedLimitChanged;

  double _prevLat = 0, _prevLon = 0, _computedBearing = 0, _lastSpeedMps = 0;
  int _lastLocationTime = 0, _lastProcessedAt = 0, _lastLayer = 0;

  AlertServiceHandler({
    required this.alertEngine, required this.audioEngine,
    required this.alertRepository, required this.tascoMapEngine,
    required this.settings, required this.onUserStateChanged,
    required this.onActiveAlertsChanged, required this.onSpeedLimitChanged,
  });

  void processLocation(Position location) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = _lastProcessedAt == 0 ? 0.1 : (now - _lastProcessedAt) / 1000.0;
    _lastProcessedAt = now;

    // Speed filtering
    var currentSpeed = location.speed;
    if (location.accuracy > 40) {
      currentSpeed = _lastSpeedMps < 1.0 ? 0 : _lastSpeedMps;
    } else if (_lastLocationTime != 0 && _prevLat != 0) {
      if (dt > 0 && dt < 5.0) {
        const maxAccel = 15.0;
        final maxPossibleSpeed = _lastSpeedMps + (maxAccel * dt);
        if (currentSpeed > maxPossibleSpeed && currentSpeed > 10.0) {
          final dist = GeoUtils.haversineMeters(_prevLat, _prevLon, location.latitude, location.longitude);
          final speedFromDist = dist / dt;
          if (currentSpeed > speedFromDist * 1.5) {
            currentSpeed = speedFromDist.clamp(0, maxPossibleSpeed);
          }
        }
      }
    } else {
      if (currentSpeed > 1.0 && location.accuracy > 15) currentSpeed = 0;
    }
    if (currentSpeed > 55.5) currentSpeed = 55.5;
    if (currentSpeed < 0.5) currentSpeed = 0;
    _lastSpeedMps = currentSpeed;
    _lastLocationTime = now;

    // Bearing
    double bearing;
    if (location.heading != 0) {
      bearing = location.heading;
    } else if (_prevLat != 0 && currentSpeed > 1.0) {
      final dist = GeoUtils.haversineMeters(_prevLat, _prevLon, location.latitude, location.longitude);
      if (dist > 3.0) _computedBearing = GeoUtils.bearingDegrees(_prevLat, _prevLon, location.latitude, location.longitude);
      bearing = _computedBearing;
    } else {
      bearing = _computedBearing;
    }
    _prevLat = location.latitude;
    _prevLon = location.longitude;

    final user = UserState(
      currentLat: location.latitude, currentLon: location.longitude,
      speedMps: currentSpeed, bearing: bearing, timestamp: now,
      accuracyMeters: location.accuracy,
    );
    onUserStateChanged(user);
    _processAlerts(user, now);
  }

  Future<void> _processAlerts(UserState user, int now) async {
    final maxTypeDistance = settings.typeAlertDistances.values.isEmpty
        ? 200 : settings.typeAlertDistances.values.reduce((a, b) => a > b ? a : b);
    final searchRadius = maxTypeDistance + 250.0;
    final nearby = await alertRepository.loadNearby(user.currentLat, user.currentLon, searchRadius, user.bearing);

    // Speed limit resolution
    final allLayers = tascoMapEngine.getAllLayerSpeeds(user.currentLat, user.currentLon);
    final bestLayerInfo = _resolveBestLayer(allLayers, user.speedMps);
    final tascoSpeed = bestLayerInfo?.speed;
    _lastLayer = bestLayerInfo?.layer ?? _lastLayer;

    final nearestSpeedLimit = _findNearestSpeedSign(nearby, user);

    if (nearestSpeedLimit != null) {
      onSpeedLimitChanged(CurrentSpeedLimit(
        speedLimitKmh: nearestSpeedLimit.$1.speedLimit,
        distanceMeters: nearestSpeedLimit.$2,
        sourceAlertId: nearestSpeedLimit.$1.id,
        sourceAlertType: nearestSpeedLimit.$1.type,
      ));
    } else if (tascoSpeed != null) {
      onSpeedLimitChanged(CurrentSpeedLimit(speedLimitKmh: tascoSpeed, sourceAlertId: 'TASCO'));
    } else {
      onSpeedLimitChanged(const CurrentSpeedLimit());
    }

    final evaluation = alertEngine.evaluate(user, nearby, settings, now);
    onActiveAlertsChanged(evaluation.activeAlerts);
    audioEngine.enqueue(evaluation.speechQueue, settings.volume);
  }

  LayerSpeed? _resolveBestLayer(List<LayerSpeed> allLayers, double speedMps) {
    if (allLayers.isEmpty) return null;
    final relevant = allLayers.where((l) => l.distance <= 50.0).toList();
    if (relevant.isEmpty) return allLayers.reduce((a, b) => a.distance < b.distance ? a : b);
    if (relevant.length == 1) return relevant[0];
    final speedKmh = speedMps * 3.6;
    final elevated = relevant.where((l) => l.layer >= 2).toList();
    final ground = relevant.where((l) => l.layer == 0).firstOrNull;
    if (speedKmh > 70 && elevated.isNotEmpty) return elevated.reduce((a, b) => a.distance < b.distance ? a : b);
    if (speedKmh < 40 && ground != null) return ground;
    return relevant.where((l) => l.layer == _lastLayer).firstOrNull ?? relevant.reduce((a, b) => a.distance < b.distance ? a : b);
  }

  (AlertPoint, double)? _findNearestSpeedSign(List<AlertPoint> nearby, UserState user) {
    (AlertPoint, double)? best;
    double bestDistance = double.maxFinite;
    for (final point in nearby) {
      if ((point.speedLimit ?? 0) <= 0) continue;
      final dir = point.direction;
      if (dir != null && GeoUtils.headingDeltaDegrees(dir, user.bearing) > 60) continue;
      if (user.speedMps >= 1.5 && !GeoUtils.isAhead(user.currentLat, user.currentLon, user.bearing, point.lat, point.lon)) continue;
      final distance = GeoUtils.haversineMeters(user.currentLat, user.currentLon, point.lat, point.lon);
      if (distance <= 800.0 && distance < bestDistance) { bestDistance = distance; best = (point, distance); }
    }
    return best;
  }
}
