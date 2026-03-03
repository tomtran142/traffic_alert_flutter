import 'package:geolocator/geolocator.dart';

class LocationTracker {
  Stream<Position> updates({int intervalMs = 100}) {
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
}
