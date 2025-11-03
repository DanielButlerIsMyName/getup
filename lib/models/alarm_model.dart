class AlarmModel {
  final int id;
  final DateTime scheduledTime;
  final bool isEnabled;
  final bool requireShake;
  final bool requireLight;
  final String soundPath;

  AlarmModel({
    required this.id,
    required this.scheduledTime,
    this.isEnabled = true,
    this.requireShake = false,
    this.requireLight = false,
    this.soundPath = 'assets/alarm.mp3',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'scheduledTime': scheduledTime.toIso8601String(),
        'isEnabled': isEnabled,
        'requireShake': requireShake,
        'requireLight': requireLight,
        'soundPath': soundPath,
      };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        id: json['id'],
        scheduledTime: DateTime.parse(json['scheduledTime']),
        isEnabled: json['isEnabled'],
        requireShake: json['requireShake'],
        requireLight: json['requireLight'],
        soundPath: json['soundPath'],
      );
}