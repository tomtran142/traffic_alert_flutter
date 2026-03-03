import 'alert_type.dart';
import 'spoken_state.dart';

class ActiveAlert {
  final String alertId;
  final AlertType alertType;
  final double distanceMeters;
  final int? etaSeconds;
  final int? speedLimit;
  final SpokenState spokenState;
  final int? lastTriggeredAt;

  const ActiveAlert({
    required this.alertId, required this.alertType, required this.distanceMeters,
    this.etaSeconds, this.speedLimit, required this.spokenState, this.lastTriggeredAt,
  });
}
