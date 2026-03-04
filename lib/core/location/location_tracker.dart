import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationTracker {
  Stream<Position> updates({int intervalMs = 100}) {
    if (kIsWeb) {
      return _simulatedRoute(intervalMs: intervalMs);
    }
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: Duration(milliseconds: intervalMs),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'WYN Traffic Alert',
          notificationText: 'Đang theo dõi vị trí...',
          enableWakeLock: true,
        ),
      ),
    );
  }

  /// Giả lập di chuyển: Giải Phóng → Bờ Hồ, ~40km/h
  Stream<Position> _simulatedRoute({int intervalMs = 100}) async* {
    // Waypoints: Giải Phóng → Đại Cồ Việt → Trần Khát Chân → Lò Đúc → Trần Nhật Duật → Bờ Hồ
    const waypoints = <List<double>>[
      [20.9980, 105.8430], // Giải Phóng (gần Phương Mai)
      [21.0000, 105.8428], // Giải Phóng
      [21.0020, 105.8425], // Giải Phóng
      [21.0040, 105.8420], // Giải Phóng / ngã tư Trường Chinh
      [21.0060, 105.8418], // Giải Phóng
      [21.0080, 105.8415], // Giải Phóng / gần Bách Khoa
      [21.0095, 105.8412], // Đại Cồ Việt / Giải Phóng
      [21.0098, 105.8430], // Đại Cồ Việt
      [21.0100, 105.8450], // Đại Cồ Việt
      [21.0103, 105.8470], // Đại Cồ Việt / Trần Khát Chân
      [21.0110, 105.8490], // Trần Khát Chân
      [21.0118, 105.8510], // Trần Khát Chân
      [21.0125, 105.8520], // Trần Khát Chân / Lò Đúc
      [21.0140, 105.8525], // Lò Đúc
      [21.0160, 105.8530], // Lò Đúc
      [21.0180, 105.8532], // Lò Đúc / Trần Nhật Duật
      [21.0200, 105.8530], // Trần Nhật Duật
      [21.0220, 105.8528], // Trần Nhật Duật
      [21.0240, 105.8525], // Trần Nhật Duật / gần cầu Chương Dương
      [21.0255, 105.8522], // Gần Bờ Hồ
      [21.0270, 105.8520], // Bờ Hồ
      [21.0285, 105.8522], // Hồ Hoàn Kiếm
    ];

    const speedMps = 11.1; // ~40 km/h
    final updateInterval = Duration(milliseconds: intervalMs.clamp(200, 2000));

    while (true) {
      for (var i = 0; i < waypoints.length - 1; i++) {
        final startLat = waypoints[i][0];
        final startLon = waypoints[i][1];
        final endLat = waypoints[i + 1][0];
        final endLon = waypoints[i + 1][1];

        // Khoảng cách giữa 2 waypoint
        final dLat = (endLat - startLat) * 111320;
        final dLon = (endLon - startLon) * 111320 * cos(startLat * pi / 180);
        final segmentDist = sqrt(dLat * dLat + dLon * dLon);
        final segmentTime = segmentDist / speedMps;
        final steps = (segmentTime * 1000 / updateInterval.inMilliseconds).ceil().clamp(1, 10000);

        for (var s = 0; s < steps; s++) {
          final t = s / steps;
          final lat = startLat + (endLat - startLat) * t;
          final lon = startLon + (endLon - startLon) * t;

          // Bearing
          final bearing = atan2(dLon, dLat) * 180 / pi;

          yield Position(
            latitude: lat,
            longitude: lon,
            timestamp: DateTime.now(),
            accuracy: 5.0,
            altitude: 10.0,
            altitudeAccuracy: 1.0,
            heading: (bearing + 360) % 360,
            headingAccuracy: 5.0,
            speed: speedMps,
            speedAccuracy: 1.0,
          );
          await Future.delayed(updateInterval);
        }
      }
      // Đến Bờ Hồ → quay lại từ đầu
    }
  }
}
