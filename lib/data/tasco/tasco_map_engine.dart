import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../core/engine/geo_utils.dart';

class LayerSpeed {
  final int layer;
  final int speed;
  final double distance;
  const LayerSpeed(this.layer, this.speed, this.distance);
}

class TascoMapEngine {
  ByteData? _buffer;
  int _numEntries = 0;
  double _gridSize = 0.01;
  bool _hasLayer = false;
  int _entrySize = 9;
  final Map<int, int> _gridStartIndices = {};
  final Map<int, int> _gridEndIndices = {};
  bool isLoaded = false;
  String? lastError;

  Future<void> load() async {
    try {
      final data = await rootBundle.load('assets/tasco.map');
      _buffer = data;

      final magicBytes = List.generate(8, (i) => data.getUint8(i));
      final magic = String.fromCharCodes(magicBytes);

      switch (magic) {
        case 'TASCOMA2': _entrySize = 10; _hasLayer = true;
        case 'TASCOMAP': _entrySize = 9; _hasLayer = false;
        default: lastError = 'Invalid magic: $magic'; _buffer = null; return;
      }

      _gridSize = data.getFloat32(8, Endian.little);
      _numEntries = data.getInt32(12, Endian.little);
      if (_numEntries <= 0 || _numEntries > 10000000) {
        lastError = 'Invalid entry count: $_numEntries'; _buffer = null; return;
      }

      int lastGk = -1;
      for (var i = 0; i < _numEntries; i++) {
        final off = 16 + i * _entrySize;
        if (off + _entrySize > data.lengthInBytes) break;
        final ilat = data.getInt32(off, Endian.little);
        final ilon = data.getInt32(off + 4, Endian.little);
        final lat = ilat / 1000000.0;
        final lon = ilon / 1000000.0;
        final latG = (lat / _gridSize).toInt();
        final lonG = (lon / _gridSize).toInt();
        final gk = (latG << 16) | (lonG & 0xFFFF);
        if (gk != lastGk) {
          if (lastGk != -1) _gridEndIndices[lastGk] = i - 1;
          _gridStartIndices[gk] = i;
          lastGk = gk;
        }
      }
      if (lastGk != -1) _gridEndIndices[lastGk] = _numEntries - 1;
      isLoaded = true;
    } catch (e) { lastError = e.toString(); }
  }

  int? getSpeedLimit(double lat, double lon, {int? layer}) {
    final buf = _buffer;
    if (buf == null || !isLoaded) return null;
    final centerLatG = (lat / _gridSize).toInt();
    final centerLonG = (lon / _gridSize).toInt();
    var minDistance = double.maxFinite;
    int? bestSpeed;

    for (var dgLat = -2; dgLat <= 2; dgLat++) {
      for (var dgLon = -2; dgLon <= 2; dgLon++) {
        final gk = ((centerLatG + dgLat) << 16) | ((centerLonG + dgLon) & 0xFFFF);
        final startIdx = _gridStartIndices[gk];
        if (startIdx == null) continue;
        final endIdx = _gridEndIndices[gk] ?? startIdx;
        for (var idx = startIdx; idx <= endIdx; idx++) {
          final off = 16 + idx * _entrySize;
          final ilat = buf.getInt32(off, Endian.little);
          final ilon = buf.getInt32(off + 4, Endian.little);
          final speed = buf.getUint8(off + 8);
          final ptLayer = _hasLayer ? buf.getUint8(off + 9) : 0;
          if (layer != null && ptLayer != layer) continue;
          final dist = GeoUtils.haversineMeters(lat, lon, ilat / 1000000.0, ilon / 1000000.0);
          if (dist < minDistance) { minDistance = dist; bestSpeed = speed; }
        }
      }
    }
    return minDistance <= 1000.0 ? bestSpeed : null;
  }

  List<LayerSpeed> getAllLayerSpeeds(double lat, double lon) {
    final buf = _buffer;
    if (buf == null || !isLoaded) return [];
    final centerLatG = (lat / _gridSize).toInt();
    final centerLonG = (lon / _gridSize).toInt();
    final layerMap = <int, LayerSpeed>{};

    for (var dgLat = -2; dgLat <= 2; dgLat++) {
      for (var dgLon = -2; dgLon <= 2; dgLon++) {
        final gk = ((centerLatG + dgLat) << 16) | ((centerLonG + dgLon) & 0xFFFF);
        final startIdx = _gridStartIndices[gk];
        if (startIdx == null) continue;
        final endIdx = _gridEndIndices[gk] ?? startIdx;
        for (var idx = startIdx; idx <= endIdx; idx++) {
          final off = 16 + idx * _entrySize;
          final ilat = buf.getInt32(off, Endian.little);
          final ilon = buf.getInt32(off + 4, Endian.little);
          final speed = buf.getUint8(off + 8);
          final layer = _hasLayer ? buf.getUint8(off + 9) : 0;
          final dist = GeoUtils.haversineMeters(lat, lon, ilat / 1000000.0, ilon / 1000000.0);
          if (dist <= 1000.0) {
            final existing = layerMap[layer];
            if (existing == null || dist < existing.distance) {
              layerMap[layer] = LayerSpeed(layer, speed, dist);
            }
          }
        }
      }
    }
    return layerMap.values.toList();
  }
}
