import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_alert/core/engine/geo_utils.dart';

void main() {
  group('haversineMeters', () {
    test('same point returns 0', () {
      expect(GeoUtils.haversineMeters(10.0, 106.0, 10.0, 106.0), closeTo(0, 0.1));
    });
    test('known distance HCM to Hanoi', () {
      final d = GeoUtils.haversineMeters(10.8231, 106.6297, 21.0285, 105.8542);
      expect(d, closeTo(1138000, 50000));
    });
  });

  group('bearingDegrees', () {
    test('due north', () {
      expect(GeoUtils.bearingDegrees(10.0, 106.0, 11.0, 106.0), closeTo(0, 1));
    });
    test('due east', () {
      expect(GeoUtils.bearingDegrees(10.0, 106.0, 10.0, 107.0), closeTo(90, 2));
    });
  });

  group('isAhead', () {
    test('point ahead returns true', () {
      expect(GeoUtils.isAhead(10.0, 106.0, 0, 10.01, 106.0), true);
    });
    test('point behind returns false', () {
      expect(GeoUtils.isAhead(10.0, 106.0, 0, 9.99, 106.0), false);
    });
  });

  group('headingDeltaDegrees', () {
    test('same heading', () {
      expect(GeoUtils.headingDeltaDegrees(90, 90), closeTo(0, 0.01));
    });
    test('opposite heading', () {
      expect(GeoUtils.headingDeltaDegrees(0, 180), closeTo(180, 0.01));
    });
    test('wrap-around', () {
      expect(GeoUtils.headingDeltaDegrees(350, 10), closeTo(20, 0.01));
    });
  });
}
