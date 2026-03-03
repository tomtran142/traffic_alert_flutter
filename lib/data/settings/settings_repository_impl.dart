import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/model/models.dart';
import '../../domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final _controller = StreamController<AlertSettings>.broadcast();
  AlertSettings _current = defaultAlertSettings();
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final enabled = csvAlertTypes.where((t) => prefs.getBool('enabled_${t.name}') ?? true).toSet();
    final typeDistances = Map<AlertType, int>.from(defaultTypeAlertDistances);
    for (final type in defaultTypeAlertDistances.keys) {
      typeDistances[type] = prefs.getInt('type_distance_${type.name}') ?? defaultTypeAlertDistances[type]!;
    }
    _current = AlertSettings(
      enabledTypes: enabled.isEmpty ? csvAlertTypes : enabled,
      triggerDistances: TriggerDistances(
        farMeters: prefs.getInt('trigger_far') ?? 800,
        midMeters: prefs.getInt('trigger_mid') ?? 400,
        nearMeters: prefs.getInt('trigger_near') ?? 150,
      ),
      typeAlertDistances: typeDistances,
      volume: prefs.getDouble('volume') ?? 1.0,
      cooldownSeconds: prefs.getInt('cooldown') ?? 25,
      maxGpsAccuracyMeters: prefs.getDouble('max_accuracy') ?? 80.0,
      enableBackground: prefs.getBool('background_enabled') ?? true,
      showFloatingBubble: prefs.getBool('show_floating_bubble') ?? false,
      autoShowOnMaps: prefs.getBool('auto_show_on_maps') ?? false,
    );
    _controller.add(_current);
  }

  @override
  Stream<AlertSettings> get settingsStream async* {
    await _ensureLoaded();
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> updateEnabledType(String type, bool enabled) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled_$type', enabled);
    final parsed = AlertType.values.where((t) => t.name == type).firstOrNull;
    if (parsed == null) return;
    final newEnabled = Set<AlertType>.from(_current.enabledTypes);
    enabled ? newEnabled.add(parsed) : newEnabled.remove(parsed);
    _current = _current.copyWith(enabledTypes: newEnabled);
    _controller.add(_current);
  }

  @override
  Future<void> updateVolume(double volume) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume.clamp(0.0, 1.0));
    _current = _current.copyWith(volume: volume.clamp(0.0, 1.0));
    _controller.add(_current);
  }

  @override
  Future<void> updateTriggerDistances(int far, int mid, int near) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trigger_far', far.clamp(200, 1500));
    await prefs.setInt('trigger_mid', mid.clamp(100, 800));
    await prefs.setInt('trigger_near', near.clamp(50, 400));
    _current = _current.copyWith(triggerDistances: TriggerDistances(farMeters: far, midMeters: mid, nearMeters: near));
    _controller.add(_current);
  }

  @override
  Future<void> updateBackground(bool enabled) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_enabled', enabled);
    _current = _current.copyWith(enableBackground: enabled);
    _controller.add(_current);
  }

  @override
  Future<void> updateShowFloatingBubble(bool enabled) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_floating_bubble', enabled);
    _current = _current.copyWith(showFloatingBubble: enabled);
    _controller.add(_current);
  }

  @override
  Future<void> updateAutoShowOnMaps(bool enabled) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_show_on_maps', enabled);
    _current = _current.copyWith(autoShowOnMaps: enabled);
    _controller.add(_current);
  }

  void dispose() { _controller.close(); }
}
