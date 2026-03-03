import 'package:flutter/material.dart';
import '../../domain/model/models.dart';
import '../../presentation/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final AlertSettings? settings;
  final void Function(AlertType, bool) onTypeChanged;
  final void Function(double) onVolumeChanged;
  final void Function(bool) onBackgroundChanged;
  final void Function(int, int, int) onDistanceChanged;
  const SettingsScreen({super.key, required this.settings, required this.onTypeChanged, required this.onVolumeChanged, required this.onBackgroundChanged, required this.onDistanceChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _volume;
  late int _far, _mid, _near;

  @override
  void initState() { super.initState(); _sync(); }

  @override
  void didUpdateWidget(SettingsScreen old) { super.didUpdateWidget(old); if (old.settings != widget.settings) _sync(); }

  void _sync() {
    final s = widget.settings;
    if (s == null) return;
    _volume = s.volume; _far = s.triggerDistances.farMeters; _mid = s.triggerDistances.midMeters; _near = s.triggerDistances.nearMeters;
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    if (settings == null) return const Center(child: Text('Loading settings...'));

    return Column(children: [
      Container(width: double.infinity, color: AppTheme.primaryGreen, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: const SafeArea(bottom: false, child: Text('Cài đặt', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        _sectionTitle('Hiển thị'),
        Card(child: SwitchListTile(title: const Text('Theo dõi vị trí dưới nền'), value: settings.enableBackground, onChanged: widget.onBackgroundChanged, activeTrackColor: AppTheme.primaryGreen)),
        const SizedBox(height: 16),
        _sectionTitle('Âm thanh'),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Âm lượng: ${(_volume * 100).toInt()}%'),
          Slider(value: _volume, activeColor: AppTheme.primaryGreen, onChanged: (v) { setState(() => _volume = v); widget.onVolumeChanged(v); }),
        ]))),
        const SizedBox(height: 16),
        _sectionTitle('Khoảng cách cảnh báo'),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _distanceSlider('Xa: ${_far}m', _far.toDouble(), 400, 1500, (v) { setState(() => _far = v.toInt()); widget.onDistanceChanged(_far, _mid, _near); }),
          const Divider(),
          _distanceSlider('Trung bình: ${_mid}m', _mid.toDouble(), 150, 800, (v) { setState(() => _mid = v.toInt()); widget.onDistanceChanged(_far, _mid, _near); }),
          const Divider(),
          _distanceSlider('Gần: ${_near}m', _near.toDouble(), 50, 400, (v) { setState(() => _near = v.toInt()); widget.onDistanceChanged(_far, _mid, _near); }),
        ]))),
        const SizedBox(height: 16),
        _sectionTitle('Loại cảnh báo'),
        Card(child: Column(children: csvAlertTypes.map((type) =>
          SwitchListTile(title: Text(type.displayLabel), value: settings.enabledTypes.contains(type), onChanged: (v) => widget.onTypeChanged(type, v), activeTrackColor: AppTheme.primaryGreen)).toList())),
        const SizedBox(height: 32),
      ])),
    ]);
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));

  Widget _distanceSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), Slider(value: value, min: min, max: max, activeColor: AppTheme.primaryGreen, onChanged: onChanged)]);
}
