import 'active_alert.dart';
import 'alert_speech_event.dart';

class AlertEvaluationResult {
  final List<ActiveAlert> activeAlerts;
  final List<AlertSpeechEvent> speechQueue;
  const AlertEvaluationResult({required this.activeAlerts, required this.speechQueue});
}
