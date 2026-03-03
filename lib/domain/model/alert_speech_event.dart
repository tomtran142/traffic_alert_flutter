import 'alert_point.dart';
import 'trigger_level.dart';

class AlertSpeechEvent {
  final AlertPoint alertPoint;
  final TriggerLevel level;
  final double distanceMeters;
  const AlertSpeechEvent({required this.alertPoint, required this.level, required this.distanceMeters});
}
