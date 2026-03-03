import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/model/models.dart';
import 'audio_mapping_provider.dart';

class AlertAudioEngine {
  final AudioMappingProvider _mappingProvider;
  final _player = AudioPlayer();
  final _queue = <_PlaybackItem>[];
  bool _processing = false;

  AlertAudioEngine(this._mappingProvider);

  void enqueue(List<AlertSpeechEvent> events, double volume) {
    for (final event in events) {
      _queue.add(_PlaybackItem(event, volume.clamp(0.0, 1.0)));
    }
    _processQueue();
  }

  Future<void> playAssets(List<String> paths, double volume) async {
    for (final path in paths) {
      try {
        await _player.setVolume(volume.clamp(0.0, 1.0));
        await _player.play(AssetSource(path));
        await _player.onPlayerComplete.first.timeout(const Duration(seconds: 10), onTimeout: () {});
      } catch (_) {}
    }
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    while (_queue.isNotEmpty) {
      final item = _queue.removeAt(0);
      await _playInternal(item);
    }
    _processing = false;
  }

  Future<void> _playInternal(_PlaybackItem item) async {
    try {
      final mapping = await _mappingProvider.load();
      final type = item.event.alertPoint.type;
      final audioKey = mapping.typeToAudioKey[type] ?? item.event.alertPoint.audioKey;
      final assetPath = mapping.audioKeyToAsset[audioKey];

      if (assetPath != null) {
        await _player.setVolume(item.volume);
        await _player.play(AssetSource(assetPath));
        await _player.onPlayerComplete.first.timeout(const Duration(seconds: 10), onTimeout: () {});

        if (type == AlertType.speedSign) {
          final limit = item.event.alertPoint.speedLimit;
          if (limit != null) {
            await _player.play(AssetSource('audio/speed/$limit.mp3'));
            await _player.onPlayerComplete.first.timeout(const Duration(seconds: 10), onTimeout: () {});
          }
        }
      }
    } catch (_) {}
  }

  void dispose() { _player.dispose(); }
}

class _PlaybackItem {
  final AlertSpeechEvent event;
  final double volume;
  const _PlaybackItem(this.event, this.volume);
}
