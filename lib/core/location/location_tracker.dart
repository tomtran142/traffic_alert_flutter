import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationTracker {
  Stream<Position> updates({int intervalMs = 100}) {
    if (kIsWeb) {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
    }
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: Duration(milliseconds: intervalMs),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'VETC Giao Thông',
          notificationText: 'Đang theo dõi vị trí...',
          enableWakeLock: true,
        ),
      ),
    );
  }
}
