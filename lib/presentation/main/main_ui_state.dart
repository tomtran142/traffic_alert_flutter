import '../../domain/model/models.dart';

class MainUiState {
  final UserState? userState;
  final ActiveAlert? nearestAlert;
  final List<ActiveAlert> upcomingAlerts;
  final String gpsStatus;
  final int dataCount;
  final bool serviceRunning;
  final AlertSettings? settings;
  final int deviceSpeedKmh;
  final CurrentSpeedLimit currentSpeedLimit;
  final ImportProgress importProgress;
  final bool isMapLoaded;
  final String? mapErrorMessage;

  const MainUiState({
    this.userState, this.nearestAlert, this.upcomingAlerts = const [],
    this.gpsStatus = 'Waiting for GPS', this.dataCount = 0,
    this.serviceRunning = false, this.settings, this.deviceSpeedKmh = 0,
    this.currentSpeedLimit = const CurrentSpeedLimit(),
    this.importProgress = const ImportProgress(),
    this.isMapLoaded = false, this.mapErrorMessage,
  });
}
