enum ShakeIntensity { light, medium, strong }
enum BrightnessThreshold { low, normal, high }

extension EnumDisplayName on Enum {
  String get displayName {
    final n = name;
    if (n.isEmpty) return n;
    return n[0].toUpperCase() + n.substring(1);
  }
}

class AlarmModel {
  final int id;
  final DateTime scheduledTime;
  final bool isEnabled;
  final ShakeIntensity shakeIntensity;
  final BrightnessThreshold brightnessThreshold;
  final String audioPath;

  AlarmModel({
    required this.id,
    required this.scheduledTime,
    this.isEnabled = true,
    this.shakeIntensity = ShakeIntensity.medium,
    this.brightnessThreshold = BrightnessThreshold.normal,
    this.audioPath = 'assets/marimba.mp3',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'scheduledTime': scheduledTime.toIso8601String(),
    'isEnabled': isEnabled,
    'shakeIntensity': shakeIntensity.name,
    'brightnessThreshold': brightnessThreshold.name,
    'soundPath': audioPath,
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    ShakeIntensity parseShake(String? value) {
      if (value == null) return ShakeIntensity.medium;
      return ShakeIntensity.values.firstWhere(
            (e) => e.name == value,
        orElse: () => ShakeIntensity.medium,
      );
    }

    BrightnessThreshold parseBrightness(String? value) {
      if (value == null) return BrightnessThreshold.normal;
      return BrightnessThreshold.values.firstWhere(
            (e) => e.name == value,
        orElse: () => BrightnessThreshold.normal,
      );
    }

    return AlarmModel(
      id: json['id'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isEnabled: json['isEnabled'] ?? true,
      shakeIntensity: parseShake(json['shakeIntensity'] as String?),
      brightnessThreshold:
      parseBrightness(json['brightnessThreshold'] as String?),
      audioPath: json['soundPath'] ?? 'assets/marimba.mp3',
    );
  }
}
