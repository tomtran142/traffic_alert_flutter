import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/alert_audio_engine.dart';
import '../core/audio/audio_mapping_provider.dart';
import '../core/engine/alert_engine.dart';
import '../core/location/location_tracker.dart';
import '../data/binary/binary_alert_repository.dart';
import '../data/settings/settings_repository_impl.dart';
import '../data/tasco/tasco_map_engine.dart';
import '../domain/model/models.dart';

final alertRepositoryProvider = Provider<BinaryAlertRepository>((ref) => BinaryAlertRepository());
final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) => SettingsRepositoryImpl());
final alertEngineProvider = Provider<AlertEngine>((ref) => AlertEngine());
final audioMappingProvider = Provider<AudioMappingProvider>((ref) => AudioMappingProvider());
final audioEngineProvider = Provider<AlertAudioEngine>((ref) => AlertAudioEngine(ref.read(audioMappingProvider)));
final locationTrackerProvider = Provider<LocationTracker>((ref) => LocationTracker());
final tascoMapEngineProvider = Provider<TascoMapEngine>((ref) {
  final engine = TascoMapEngine();
  engine.load();
  return engine;
});

final userStateProvider = StateProvider<UserState?>((ref) => null);
final activeAlertsProvider = StateProvider<List<ActiveAlert>>((ref) => []);
final currentSpeedLimitProvider = StateProvider<CurrentSpeedLimit>((ref) => const CurrentSpeedLimit());
final importProgressProvider = StateProvider<ImportProgress>((ref) => const ImportProgress());
final serviceRunningProvider = StateProvider<bool>((ref) => false);

final settingsStreamProvider = StreamProvider<AlertSettings>((ref) {
  return ref.read(settingsRepositoryProvider).settingsStream;
});

final alertCountProvider = StreamProvider<int>((ref) {
  return ref.read(alertRepositoryProvider).observeCount();
});
