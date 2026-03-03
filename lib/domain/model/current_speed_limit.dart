import 'alert_type.dart';

class CurrentSpeedLimit {
  final int? speedLimitKmh;
  final double? distanceMeters;
  final String? sourceAlertId;
  final AlertType? sourceAlertType;
  const CurrentSpeedLimit({this.speedLimitKmh, this.distanceMeters, this.sourceAlertId, this.sourceAlertType});
}
