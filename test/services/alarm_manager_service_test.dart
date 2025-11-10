import 'package:alarm/alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:getup/services/alarm_api.dart';
import 'package:getup/services/alarm_manager_service.dart';

class _MockAlarmApi extends Mock implements AlarmApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      AlarmSettings(
        id: 1,
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
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
      ),
    );
  });

  group('AlarmManagerService', () {
    late _MockAlarmApi mockApi;
    late AlarmManagerService service;

    setUp(() {
      mockApi = _MockAlarmApi();
      service = AlarmManagerService(alarmApi: mockApi);
    });

    test('initialize delegates to AlarmApi.init', () async {
      when(() => mockApi.init()).thenAnswer((_) async {});

      await service.initialize();

      verify(() => mockApi.init()).called(1);
      verifyNoMoreInteractions(mockApi);
    });

    test('scheduleAlarm builds expected AlarmSettings and calls set', () async {
      final scheduledTime = DateTime.now()
          .add(const Duration(minutes: 5))
          .toUtc();

      // Capture the AlarmSettings passed to set(...)
      late AlarmSettings captured;
      when(
        () => mockApi.set(alarmSettings: any(named: 'alarmSettings')),
      ).thenAnswer((invocation) async {
        captured = invocation.namedArguments[#alarmSettings] as AlarmSettings;
      });

      await service.scheduleAlarm(42, scheduledTime);

      // Verify delegation occurred
      verify(
        () => mockApi.set(alarmSettings: any(named: 'alarmSettings')),
      ).called(1);

      // Spot-check critical fields on constructed AlarmSettings
      expect(captured.id, 42);
      expect(captured.dateTime.toUtc(), scheduledTime);
      expect(captured.assetAudioPath, 'assets/marimba.mp3');
      expect(captured.loopAudio, true);
      expect(captured.vibrate, true);
      expect(captured.volumeSettings.volume, 1.0);
      expect(captured.volumeSettings.volumeEnforced, true);
      expect(captured.warningNotificationOnKill, true);
      expect(captured.androidFullScreenIntent, true);
      expect(captured.notificationSettings.title, 'ALARM!');
      expect(captured.notificationSettings.body, 'Time to wake up!');
      expect(captured.notificationSettings.stopButton, 'Stop');

      verifyNoMoreInteractions(mockApi);
    });

    test('cancelAlarm delegates to AlarmApi.stop', () async {
      when(() => mockApi.stop(7)).thenAnswer((_) async {});

      await service.cancelAlarm(7);

      verify(() => mockApi.stop(7)).called(1);
      verifyNoMoreInteractions(mockApi);
    });
  });
}
