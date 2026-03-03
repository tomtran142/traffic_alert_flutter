import 'alert_type.dart';
import 'trigger_distances.dart';

const Map<AlertType, int> defaultTypeAlertDistances = {
  AlertType.speedCamera: 200, AlertType.trafficLight: 50, AlertType.speedSign: 100,
  AlertType.noOvertakingStart: 100, AlertType.noOvertakingEnd: 100,
  AlertType.residentialAreaStart: 100, AlertType.residentialAreaEnd: 100,
  AlertType.restArea: 200, AlertType.noParking: 100, AlertType.noEntry: 100,
  AlertType.noTurn: 100, AlertType.noUTurn: 100, AlertType.infoSign: 100,
};

class AlertSettings {
  final Set<AlertType> enabledTypes;
  final TriggerDistances triggerDistances;
  final Map<AlertType, int> typeAlertDistances;
  final double volume;
  final int cooldownSeconds;
  final double maxGpsAccuracyMeters;
  final bool enableBackground;
  final bool showFloatingBubble;
  final bool autoShowOnMaps;

  const AlertSettings({
    required this.enabledTypes, this.triggerDistances = const TriggerDistances(),
    this.typeAlertDistances = defaultTypeAlertDistances, this.volume = 1.0,
    this.cooldownSeconds = 25, this.maxGpsAccuracyMeters = 80.0,
    this.enableBackground = true, this.showFloatingBubble = false, this.autoShowOnMaps = false,
  });

  AlertSettings copyWith({
    Set<AlertType>? enabledTypes, TriggerDistances? triggerDistances,
    Map<AlertType, int>? typeAlertDistances, double? volume, int? cooldownSeconds,
    double? maxGpsAccuracyMeters, bool? enableBackground, bool? showFloatingBubble, bool? autoShowOnMaps,
  }) => AlertSettings(
    enabledTypes: enabledTypes ?? this.enabledTypes,
    triggerDistances: triggerDistances ?? this.triggerDistances,
    typeAlertDistances: typeAlertDistances ?? this.typeAlertDistances,
    volume: volume ?? this.volume,
    cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    maxGpsAccuracyMeters: maxGpsAccuracyMeters ?? this.maxGpsAccuracyMeters,
    enableBackground: enableBackground ?? this.enableBackground,
    showFloatingBubble: showFloatingBubble ?? this.showFloatingBubble,
    autoShowOnMaps: autoShowOnMaps ?? this.autoShowOnMaps,
  );
}

AlertSettings defaultAlertSettings() => AlertSettings(enabledTypes: csvAlertTypes);
