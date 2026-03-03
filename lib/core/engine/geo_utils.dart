import 'dart:math';

class GeoUtils {
  static const double _earthRadiusM = 6371000.0;

  static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusM * c;
  }

  static double bearingDegrees(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);
    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);
    final deg = _toDegrees(atan2(y, x));
    return (deg + 360) % 360;
  }

  static bool isAhead(double lat, double lon, double bearing, double targetLat, double targetLon) {
    final toTarget = bearingDegrees(lat, lon, targetLat, targetLon);
    return headingDeltaDegrees(toTarget, bearing) <= 90;
  }

  static double headingDeltaDegrees(double a, double b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  static double cosRadians(double degrees) => cos(_toRadians(degrees));
  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
