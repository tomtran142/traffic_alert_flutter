import 'package:flutter/material.dart';
import '../../domain/model/models.dart';
import '../../presentation/theme/app_theme.dart';
import 'main_ui_state.dart';
import 'vietnam_traffic_sign.dart';

class MainScreen extends StatelessWidget {
  final MainUiState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  const MainScreen({super.key, required this.state, required this.onStart, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity, color: AppTheme.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SafeArea(bottom: false, child: Row(children: [
          const Text('VETC Giao Thông', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: state.serviceRunning ? AppTheme.accentGreen : AppTheme.alertRed)),
        ])),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        const SizedBox(height: 16),
        _buildSpeedDashboard(),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 16),
        _buildSectionHeader('Cảnh báo gần nhất'),
        if (state.nearestAlert != null) _buildAlertItem(state.nearestAlert!),
        if (state.upcomingAlerts.length > 1) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Sắp tới'),
          ...state.upcomingAlerts.skip(1).map(_buildAlertItem),
        ],
        const SizedBox(height: 32),
      ])),
    ]);
  }

  Widget _buildSpeedDashboard() {
    final speedLimit = state.currentSpeedLimit.speedLimitKmh;
    final isSpeeding = speedLimit != null && state.deviceSpeedKmh > speedLimit;
    return Row(children: [
      Expanded(flex: 13, child: Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Text('${state.deviceSpeedKmh}', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: isSpeeding ? AppTheme.alertRed : AppTheme.primaryGreen)),
          const Text('km/h', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ])))),
      const SizedBox(width: 12),
      Expanded(flex: 10, child: AspectRatio(aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.alertRed, width: 8)),
          child: Center(child: Text(speedLimit?.toString() ?? '--', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)))))),
    ]);
  }

  Widget _buildControls() => Row(children: [
    Expanded(child: ElevatedButton.icon(onPressed: onStart, icon: const Icon(Icons.play_arrow), label: const Text('Bắt đầu', style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
    const SizedBox(width: 12),
    Expanded(child: OutlinedButton.icon(onPressed: onStop, icon: const Icon(Icons.close), label: const Text('Dừng', style: TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.alertRed, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
  ]);

  Widget _buildAlertItem(ActiveAlert alert) => Card(margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      VietnamTrafficSign(type: alert.alertType, size: 36, label: alert.speedLimit?.toString()),
      const SizedBox(width: 12),
      Expanded(child: Text(alert.alertType.displayLabel, style: const TextStyle(fontWeight: FontWeight.w600))),
      Text('${alert.distanceMeters.toInt()}m', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.alertRed)),
    ])));

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
}
