class AlarmConstants {
  AlarmConstants._();

  static const int shakeCountLight = 5;
  static const int shakeCountMedium = 10;
  static const int shakeCountStrong = 20;

  // (m/s^2)
  static const double shakeThresholdLight = 12.0;
  static const double shakeThresholdMedium = 18.0;
  static const double shakeThresholdStrong = 24.0;

  static const Duration shakeCooldown = Duration(milliseconds: 500);

  static const int lightThresholdLow = 300;
  static const int lightThresholdNormal = 400;
  static const int lightThresholdHigh = 500;

  static const String sensorChannel = 'com.getup.alarm/sensors';
  static const String lightEventChannel = 'com.getup.alarm/light_sensor';
  static const String alarmControlChannel = 'com.getup.alarm/control';

  static const String methodStartLightSensor = 'startLightSensor';
  static const String methodStopLightSensor = 'stopLightSensor';
  static const String methodStartAlarmService = 'startAlarmService';
  static const String methodStopAlarmService = 'stopAlarmService';

  static const String storageKeyAlarms = 'alarms';

  static const String notificationTitle = 'ALARM!';
  static const String notificationBody = 'Time to wake up!';
  static const String notificationStopButton = 'Stop';

  static const double alarmVolume = 1.0;
  static const bool alarmVolumeEnforced = true;
  static const bool alarmLoopAudio = true;
  static const bool alarmVibrate = true;
}
