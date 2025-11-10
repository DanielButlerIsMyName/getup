import 'package:alarm/alarm.dart';
import 'alarm_api.dart';
import 'package:flutter/material.dart';

class AlarmManagerService {
  final AlarmApi alarmApi;

  AlarmManagerService({AlarmApi? alarmApi})
    : alarmApi = alarmApi ?? PackageAlarmApi();

  Future<void> initialize() async {
    await alarmApi.init();
    debugPrint('Alarm service initialized');
  }

  Future<void> scheduleAlarm(
    int id,
    DateTime scheduledTime, {
    bool requireShake = false,
    bool requireLight = false,
  }) async {
    debugPrint('Scheduling alarm #$id for $scheduledTime');
    debugPrint('Current time: ${DateTime.now()}');
    debugPrint('Time until alarm: ${scheduledTime.difference(DateTime.now())}');

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/marimba.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: const NotificationSettings(
        title: 'ALARM!',
        body: 'Time to wake up!',
        stopButton: 'Stop',
      ),
    );

    await alarmApi.set(alarmSettings: alarmSettings);
    debugPrint('Alarm #$id scheduled successfully');
  }

  Future<void> cancelAlarm(int id) async {
    debugPrint('Cancelling alarm #$id');
    await alarmApi.stop(id);
  }
}
