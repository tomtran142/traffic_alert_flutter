import '../model/alert_settings.dart';

abstract class SettingsRepository {
  Stream<AlertSettings> get settingsStream;
  Future<void> updateEnabledType(String type, bool enabled);
  Future<void> updateVolume(double volume);
  Future<void> updateTriggerDistances(int far, int mid, int near);
  Future<void> updateBackground(bool enabled);
  Future<void> updateShowFloatingBubble(bool enabled);
  Future<void> updateAutoShowOnMaps(bool enabled);
}
