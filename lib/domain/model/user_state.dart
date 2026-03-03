class UserState {
  final double currentLat;
  final double currentLon;
  final double speedMps;
  final double bearing;
  final int timestamp;
  final double accuracyMeters;

  const UserState({
    required this.currentLat, required this.currentLon, required this.speedMps,
    required this.bearing, required this.timestamp, this.accuracyMeters = 999.0,
  });
}
