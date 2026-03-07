import 'dart:io' show Platform;
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
    if (Platform.isIOS || Platform.isMacOS) {
      return Geolocator.getPositionStream(
        locationSettings: const AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          activityType: ActivityType.automotiveNavigation,
          allowBackgroundLocationUpdates: true,
          showBackgroundLocationIndicator: true,
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
