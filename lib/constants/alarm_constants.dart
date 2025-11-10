/// Constants for alarm configuration and thresholds
class AlarmConstants {
  AlarmConstants._(); // Private constructor to prevent instantiation

  // Shake detection constants
  static const int shakeCountLight = 5;
  static const int shakeCountMedium = 10;
  static const int shakeCountStrong = 20;

  static const double shakeThresholdLight = 50.0;
  static const double shakeThresholdMedium = 100.0;
  static const double shakeThresholdStrong = 150.0;

  static const Duration shakeCooldown = Duration(milliseconds: 500);

  // Light sensor constants (in lux)
  static const int lightThresholdLow = 300;
  static const int lightThresholdNormal = 400;
  static const int lightThresholdHigh = 500;

  // Platform channels
  static const String sensorChannel = 'com.getup.alarm/sensors';
  static const String lightEventChannel = 'com.getup.alarm/light_sensor';
  static const String alarmControlChannel = 'com.getup.alarm/control';

  // Method channel method names
  static const String methodStartLightSensor = 'startLightSensor';
  static const String methodStopLightSensor = 'stopLightSensor';
  static const String methodStartAlarmService = 'startAlarmService';
  static const String methodStopAlarmService = 'stopAlarmService';

  // Storage keys
  static const String storageKeyAlarms = 'alarms';

  // Notification constants
  static const String notificationTitle = 'ALARM!';
  static const String notificationBody = 'Time to wake up!';
  static const String notificationStopButton = 'Stop';

  // Audio settings
  static const double alarmVolume = 1.0;
  static const bool alarmVolumeEnforced = true;
  static const bool alarmLoopAudio = true;
  static const bool alarmVibrate = true;
}

