import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:getup/models/alarm_model.dart';

import '../constants/alarm_constant.dart';

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
      loopAudio: AlarmConstants.alarmLoopAudio,
      vibrate: AlarmConstants.alarmVibrate,
      // Keep volume settings configurable via constants
      volumeSettings: const VolumeSettings.fixed(
        volume: AlarmConstants.alarmVolume,
        volumeEnforced: AlarmConstants.alarmVolumeEnforced,
      ),
      notificationSettings: const NotificationSettings(
        title: AlarmConstants.notificationTitle,
        body: AlarmConstants.notificationBody,
        stopButton: AlarmConstants.notificationStopButton,
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> cancelAlarm(int id) async {
    debugPrint('Cancelling alarm #$id');
    await Alarm.stop(id);
  }
}
