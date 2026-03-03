import 'alert_type.dart';

class AlertPoint {
  final String id;
  final AlertType type;
  final double lat;
  final double lon;
  final int? speedLimit;
  final double? direction;
  final int priority;
  final String audioKey;
  final String metadataJson;

  const AlertPoint({
    required this.id, required this.type, required this.lat, required this.lon,
    this.speedLimit, this.direction, required this.priority, required this.audioKey,
    this.metadataJson = '{}',
  });
}
