import '../model/alert_point.dart';

abstract class AlertRepository {
  Future<void> upsert(List<AlertPoint> points);
  Future<List<AlertPoint>> loadNearby(double lat, double lon, double radiusMeters, [double bearing = double.nan]);
  Future<int> count();
  Stream<int> observeCount();
}
