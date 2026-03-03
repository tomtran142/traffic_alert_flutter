import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_alert/core/engine/alert_engine.dart';
import 'package:traffic_alert/domain/model/models.dart';

void main() {
  late AlertEngine engine;

  setUp(() => engine = AlertEngine());

  test('no points returns empty result', () {
    final user = UserState(currentLat: 10.0, currentLon: 106.0, speedMps: 10, bearing: 0, timestamp: 1000);
    final result = engine.evaluate(user, [], defaultAlertSettings(), 1000);
    expect(result.activeAlerts, isEmpty);
    expect(result.speechQueue, isEmpty);
  });

  test('nearby point within type distance triggers speech', () {
    final user = UserState(currentLat: 10.0, currentLon: 106.0, speedMps: 10, bearing: 0, timestamp: 100000, accuracyMeters: 5);
    final point = AlertPoint(id: 'test1', type: AlertType.speedCamera, lat: 10.001, lon: 106.0, priority: 100, audioKey: 'speed_camera');
    final result = engine.evaluate(user, [point], defaultAlertSettings(), 100000);
    expect(result.activeAlerts.length, 1);
    expect(result.speechQueue.length, 1);
  });

  test('poor GPS accuracy skips evaluation', () {
    final user = UserState(currentLat: 10.0, currentLon: 106.0, speedMps: 10, bearing: 0, timestamp: 100000, accuracyMeters: 100);
    final point = AlertPoint(id: 'test1', type: AlertType.speedCamera, lat: 10.001, lon: 106.0, priority: 100, audioKey: 'speed_camera');
    final result = engine.evaluate(user, [point], defaultAlertSettings(), 100000);
    expect(result.speechQueue, isEmpty);
  });

  test('same point does not trigger speech twice', () {
    final user = UserState(currentLat: 10.0, currentLon: 106.0, speedMps: 10, bearing: 0, timestamp: 100000, accuracyMeters: 5);
    final point = AlertPoint(id: 'test1', type: AlertType.speedCamera, lat: 10.001, lon: 106.0, priority: 100, audioKey: 'speed_camera');
    engine.evaluate(user, [point], defaultAlertSettings(), 100000);
    final result2 = engine.evaluate(user, [point], defaultAlertSettings(), 101000);
    expect(result2.speechQueue, isEmpty);
  });
}
