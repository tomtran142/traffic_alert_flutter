import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'di/providers.dart';
import 'domain/model/models.dart';
import 'presentation/main/main_screen.dart';
import 'presentation/main/main_ui_state.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'core/service/alert_service_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TrafficAlertApp()));
}

class TrafficAlertApp extends StatelessWidget {
  const TrafficAlertApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'WYN Traffic Alert',
    theme: AppTheme.theme,
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
  );
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription<Position>? _locationSub;
  AlertServiceHandler? _handler;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.location, Permission.locationAlways, Permission.notification].request();
  }

  void _startMonitoring() {
    if (_locationSub != null) return;
    final tracker = ref.read(locationTrackerProvider);
    final alertEngine = ref.read(alertEngineProvider);
    final audioEngine = ref.read(audioEngineProvider);
    final alertRepo = ref.read(alertRepositoryProvider);
    final tascoEngine = ref.read(tascoMapEngineProvider);
    final settingsAsync = ref.read(settingsStreamProvider);
    final settings = settingsAsync.valueOrNull ?? defaultAlertSettings();

    _handler = AlertServiceHandler(
      alertEngine: alertEngine, audioEngine: audioEngine,
      alertRepository: alertRepo, tascoMapEngine: tascoEngine,
      settings: settings,
      onUserStateChanged: (user) => ref.read(userStateProvider.notifier).state = user,
      onActiveAlertsChanged: (alerts) => ref.read(activeAlertsProvider.notifier).state = alerts,
      onSpeedLimitChanged: (limit) => ref.read(currentSpeedLimitProvider.notifier).state = limit,
    );

    _locationSub = tracker.updates(intervalMs: 100).listen((position) {
      _handler?.processLocation(position);
    });
    ref.read(serviceRunningProvider.notifier).state = true;
  }

  void _stopMonitoring() {
    _locationSub?.cancel();
    _locationSub = null;
    ref.read(serviceRunningProvider.notifier).state = false;
  }

  @override
  void dispose() { _locationSub?.cancel(); _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);
    final activeAlerts = ref.watch(activeAlertsProvider);
    final speedLimit = ref.watch(currentSpeedLimitProvider);
    final serviceRunning = ref.watch(serviceRunningProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final settings = settingsAsync.valueOrNull;

    if (_handler != null && settings != null) _handler!.settings = settings;

    final uiState = MainUiState(
      userState: userState,
      nearestAlert: activeAlerts.isNotEmpty ? activeAlerts.first : null,
      upcomingAlerts: activeAlerts.take(8).toList(),
      gpsStatus: userState == null ? 'Waiting for GPS' : 'GPS ${userState.accuracyMeters.toInt()}m',
      serviceRunning: serviceRunning,
      settings: settings,
      deviceSpeedKmh: ((userState?.speedMps ?? 0) * 3.6).toInt().clamp(0, 999),
      currentSpeedLimit: speedLimit,
    );

    return Scaffold(
      body: Column(children: [
        Material(color: Colors.white, child: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Trang chủ'), Tab(text: 'Cài đặt')],
        )),
        Expanded(child: TabBarView(controller: _tabController, children: [
          MainScreen(state: uiState, onStart: _startMonitoring, onStop: _stopMonitoring),
          SettingsScreen(
            settings: settings,
            onTypeChanged: (type, enabled) => ref.read(settingsRepositoryProvider).updateEnabledType(type.name, enabled),
            onVolumeChanged: (v) => ref.read(settingsRepositoryProvider).updateVolume(v),
            onBackgroundChanged: (v) => ref.read(settingsRepositoryProvider).updateBackground(v),
            onDistanceChanged: (f, m, n) => ref.read(settingsRepositoryProvider).updateTriggerDistances(f, m, n),
          ),
        ])),
      ]),
    );
  }
}
