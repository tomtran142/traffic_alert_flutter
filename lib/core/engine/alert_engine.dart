import '../../domain/model/models.dart';
import 'geo_utils.dart';

class AlertEngine {
  final Map<String, SpokenState> _spokenStateByAlert = {};
  final Map<String, int> _cooldownByKey = {};
  final Map<String, double> _lastDistanceByAlert = {};
  final Set<String> _globalSpokenHistory = {};
  final Map<AlertType, int> _lastSpokenTimeByType = {};

  AlertEvaluationResult evaluate(UserState user, List<AlertPoint> points, AlertSettings settings, int nowMillis) {
    final active = <ActiveAlert>[];
    final speech = <AlertSpeechEvent>[];
    final maxSearchRadius = settings.typeAlertDistances.values.isEmpty
        ? 200.0
        : settings.typeAlertDistances.values.reduce((a, b) => a > b ? a : b).toDouble();
    final currentPointIds = <String>{};

    for (final point in points) {
      if (!settings.enabledTypes.contains(point.type)) continue;
      if (user.accuracyMeters > settings.maxGpsAccuracyMeters) continue;
      if (!_passesHeading(point, user.bearing)) continue;

      final distance = GeoUtils.haversineMeters(user.currentLat, user.currentLon, point.lat, point.lon);
      final typeDistance = (settings.typeAlertDistances[point.type] ?? 200).toDouble();

      if (distance > maxSearchRadius) continue;

      if (user.speedMps > 1.0 && !GeoUtils.isAhead(user.currentLat, user.currentLon, user.bearing, point.lat, point.lon)) {
        if (distance > 100.0) _globalSpokenHistory.remove(point.id);
        continue;
      }

      currentPointIds.add(point.id);

      final previousSpoken = _globalSpokenHistory.contains(point.id)
          ? SpokenState.nearSpoken
          : (_spokenStateByAlert[point.id] ?? SpokenState.none);

      final eta = user.speedMps > 0.5 ? (distance / user.speedMps).round().clamp(0, 99999) : null;

      active.add(ActiveAlert(
        alertId: point.id, alertType: point.type, distanceMeters: distance,
        etaSeconds: eta, speedLimit: point.speedLimit, spokenState: previousSpoken,
        lastTriggeredAt: _cooldownByKey['${point.id}:SPOKEN'],
      ));

      if (distance <= typeDistance && _shouldSpeak(
        point: point, distance: distance, speedMps: user.speedMps,
        previousSpoken: previousSpoken, nowMillis: nowMillis, cooldownSeconds: settings.cooldownSeconds,
      )) {
        speech.add(AlertSpeechEvent(alertPoint: point, level: TriggerLevel.near, distanceMeters: distance));
        _spokenStateByAlert[point.id] = SpokenState.nearSpoken;
        _globalSpokenHistory.add(point.id);
        _lastSpokenTimeByType[point.type] = nowMillis;
        _cooldownByKey['${point.id}:SPOKEN'] = nowMillis;
      }

      _lastDistanceByAlert[point.id] = distance;
    }

    _spokenStateByAlert.removeWhere((key, _) => !currentPointIds.contains(key));
    _lastDistanceByAlert.removeWhere((key, _) => !currentPointIds.contains(key));
    _cooldownByKey.removeWhere((key, _) => !currentPointIds.contains(key.split(':').first));

    active.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    speech.sort((a, b) {
      final priCmp = b.alertPoint.priority.compareTo(a.alertPoint.priority);
      if (priCmp != 0) return priCmp;
      return a.distanceMeters.compareTo(b.distanceMeters);
    });

    return AlertEvaluationResult(activeAlerts: active, speechQueue: speech);
  }

  bool _shouldSpeak({required AlertPoint point, required double distance, required double speedMps,
      required SpokenState previousSpoken, required int nowMillis, required int cooldownSeconds}) {
    if (previousSpoken != SpokenState.none) return false;
    final lastTypeSpoken = _lastSpokenTimeByType[point.type] ?? 0;
    if (nowMillis - lastTypeSpoken < 30000) return false;
    final cooldownKey = '${point.id}:SPOKEN';
    final lastTrigger = _cooldownByKey[cooldownKey];
    if (lastTrigger != null && nowMillis - lastTrigger < cooldownSeconds * 1000) return false;
    if (speedMps < 1.2) {
      final lastDistance = _lastDistanceByAlert[point.id];
      final delta = lastDistance != null ? lastDistance - distance : 0.0;
      if (delta < 25.0) return false;
    }
    return true;
  }

  bool _passesHeading(AlertPoint point, double userBearing) {
    final direction = point.direction;
    if (direction == null) return true;
    return GeoUtils.headingDeltaDegrees(direction, userBearing) <= 60;
  }
}
