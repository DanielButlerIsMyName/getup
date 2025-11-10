import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:getup/models/alarm_model.dart';

class AlarmManagerService {
  static Future<void> initialize() async {
    await Alarm.init();
    debugPrint('Alarm service initialized');
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    final alarmSettings = AlarmSettings(
      id: alarm.id,
      dateTime: alarm.scheduledTime,
      assetAudioPath: alarm.audioPath,
      loopAudio: true,
      vibrate: true,
      // TODO: MARC Adjust volume
      volumeSettings: const VolumeSettings.fixed(
        volume: 0.1,
        volumeEnforced: false,
      ),
      notificationSettings: const NotificationSettings(
        title: 'ALARM!',
        body: 'Time to wake up!',
        stopButton: 'Stop',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> cancelAlarm(int id) async {
    debugPrint('Cancelling alarm #$id');
    await Alarm.stop(id);
  }
}
