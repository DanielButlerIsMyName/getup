import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmManagerService {
  static Future<void> initialize() async {
    await Alarm.init();
    debugPrint('Alarm service initialized');
  }

  Future<void> scheduleAlarm(int id, DateTime scheduledTime, {bool requireShake = false, bool requireLight = false}) async {
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

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('Alarm #$id scheduled successfully');
    } catch (e, stack) {
      debugPrint('Failed to schedule alarm: $e');
      debugPrint('Stack trace: $stack');
    }
    debugPrint('Alarm #$id scheduled successfully');
  }

  Future<void> cancelAlarm(int id) async {
    debugPrint('Cancelling alarm #$id');
    await Alarm.stop(id);
  }
}