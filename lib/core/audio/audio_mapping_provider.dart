import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/model/alert_type.dart';

class AudioMapping {
  final Map<AlertType, String> typeToAudioKey;
  final Map<String, String> audioKeyToAsset;
  const AudioMapping(this.typeToAudioKey, this.audioKeyToAsset);
}

class AudioMappingProvider {
  AudioMapping? _cache;

  Future<AudioMapping> load() async {
    if (_cache != null) return _cache!;
    final typeToAudioKey = <AlertType, String>{};
    final audioKeyToAsset = <String, String>{};

    try {
      final text = await rootBundle.loadString('assets/audio_mapping.json');
      final root = jsonDecode(text) as Map<String, dynamic>;
      final typeMapJson = root['alertTypeToAudioKey'] as Map<String, dynamic>?;
      final assetMapJson = root['audioKeyToAsset'] as Map<String, dynamic>?;
      if (assetMapJson != null) {
        for (final entry in assetMapJson.entries) {
          audioKeyToAsset[entry.key] = entry.value as String;
        }
      }
      if (typeMapJson != null) {
        for (final type in AlertType.values) {
          if (typeMapJson.containsKey(type.name)) {
            final key = typeMapJson[type.name] as String;
            if (audioKeyToAsset.containsKey(key)) typeToAudioKey[type] = key;
          }
        }
      }
    } catch (_) {}

    for (final type in AlertType.values) {
      if (!typeToAudioKey.containsKey(type)) {
        final matched = _findBestMatch(type);
        if (matched != null) {
          final audioKey = 'auto_${type.name}';
          typeToAudioKey[type] = audioKey;
          audioKeyToAsset[audioKey] = 'audio/$matched.mp3';
        }
      }
    }

    _cache = AudioMapping(typeToAudioKey, audioKeyToAsset);
    return _cache!;
  }

  String? _findBestMatch(AlertType type) => switch (type) {
    AlertType.speedCamera => 'batdaughihinh',
    AlertType.speedSign => 'sapdenbienbao',
    AlertType.trafficLight => 'chuydentinhieugiaothong',
    AlertType.noOvertakingStart => 'camvuot',
    AlertType.noOvertakingEnd => 'hetcamvuot',
    AlertType.residentialAreaStart => 'batdaukhudancu',
    AlertType.residentialAreaEnd => 'hetkhudongdancu',
    AlertType.restArea => 'tramdungchan',
    AlertType.noParking => null,
    AlertType.noEntry => null,
    AlertType.noTurn => null,
    AlertType.noUTurn => null,
    AlertType.infoSign => null,
    AlertType.unknown => null,
  };
}
