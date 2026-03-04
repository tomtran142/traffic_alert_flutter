import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../core/engine/geo_utils.dart';
import '../../domain/model/models.dart';
import '../../domain/repository/alert_repository.dart';

class BinaryAlertRepository implements AlertRepository {
  static const _assetName = 'assets/data.vetc';
  static const _headerSize = 8;
  static const _recordSize = 16;

  ByteData? _buffer;
  int _recordCount = 0;
  final _countController = StreamController<int>.broadcast();
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final data = await rootBundle.load(_assetName);
      final magic = data.getUint32(0, Endian.little);
      if (magic == 0x014E5957) {
        _recordCount = data.getInt32(4, Endian.little);
        _buffer = data;
        _countController.add(_recordCount);
      }
    } catch (_) {}
  }

  @override
  Future<void> upsert(List<AlertPoint> points) async {}

  @override
  Future<List<AlertPoint>> loadNearby(double lat, double lon, double radiusMeters, [double bearing = double.nan]) async {
    await ensureLoaded();
    final bb = _buffer;
    if (bb == null) return [];

    final results = <AlertPoint>[];
    final latDelta = radiusMeters / 111320.0;
    final lonDelta = radiusMeters / (111320.0 * GeoUtils.cosRadians(lat).clamp(0.01, 1.0));

    final minLatInt = ((lat - latDelta) * 1e7).toInt();
    final maxLatInt = ((lat + latDelta) * 1e7).toInt();
    final minLonInt = ((lon - lonDelta) * 1e7).toInt();
    final maxLonInt = ((lon + lonDelta) * 1e7).toInt();

    for (var i = 0; i < _recordCount; i++) {
      final offset = _headerSize + i * _recordSize;
      if (offset + _recordSize > bb.lengthInBytes) break;
      final pLatInt = bb.getInt32(offset, Endian.little);
      final pLonInt = bb.getInt32(offset + 4, Endian.little);

      if (pLatInt >= minLatInt && pLatInt <= maxLatInt && pLonInt >= minLonInt && pLonInt <= maxLonInt) {
        final point = _readRecord(i, bb, offset, pLatInt, pLonInt);
        if (bearing.isNaN) {
          results.add(point);
        } else {
          final dir = point.direction;
          if (dir == null || GeoUtils.headingDeltaDegrees(dir, bearing) <= 90) {
            results.add(point);
          }
        }
      }
    }
    return results;
  }

  AlertPoint _readRecord(int index, ByteData bb, int offset, int latInt, int lonInt) {
    final typeIdx = bb.getUint8(offset + 8);
    final speed = bb.getUint8(offset + 9);
    final directionRaw = bb.getUint16(offset + 10, Endian.little);
    final flags = bb.getUint8(offset + 12);
    final typeId = bb.getUint16(offset + 13, Endian.little);
    final type = typeIdx < AlertType.values.length ? AlertType.values[typeIdx] : AlertType.unknown;

    return AlertPoint(
      id: 'bin_$index', type: type, lat: latInt / 1e7, lon: lonInt / 1e7,
      speedLimit: speed > 0 ? speed : null,
      direction: directionRaw != 65535 ? directionRaw.toDouble() : null,
      priority: _defaultPriority(type), audioKey: _defaultAudioKey(type),
      metadataJson: '{"flags":"$flags","type_id":"$typeId"}',
    );
  }

  @override
  Future<int> count() async { await ensureLoaded(); return _recordCount; }

  @override
  Stream<int> observeCount() {
    ensureLoaded();
    return _countController.stream;
  }

  int _defaultPriority(AlertType type) => switch (type) {
    AlertType.speedCamera => 100, AlertType.trafficLight => 90,
    AlertType.noOvertakingStart || AlertType.noOvertakingEnd => 80,
    AlertType.residentialAreaStart || AlertType.residentialAreaEnd || AlertType.restArea => 70,
    AlertType.noParking || AlertType.noEntry || AlertType.noTurn || AlertType.noUTurn => 65,
    AlertType.speedSign => 60, AlertType.infoSign => 40, AlertType.unknown => 10,
  };

  String _defaultAudioKey(AlertType type) => switch (type) {
    AlertType.speedCamera => 'speed_camera', AlertType.speedSign => 'speed_sign',
    AlertType.trafficLight => 'traffic_light', AlertType.noOvertakingStart => 'no_overtaking_start',
    AlertType.noOvertakingEnd => 'no_overtaking_end', AlertType.residentialAreaStart => 'residential_area_start',
    AlertType.residentialAreaEnd => 'residential_area_end', AlertType.restArea => 'rest_area',
    AlertType.noParking => 'no_parking', AlertType.noEntry => 'no_entry',
    AlertType.noTurn => 'no_turn', AlertType.noUTurn => 'no_u_turn',
    AlertType.infoSign => 'info_sign', AlertType.unknown => 'generic_alert',
  };

  void dispose() { _countController.close(); }
}
