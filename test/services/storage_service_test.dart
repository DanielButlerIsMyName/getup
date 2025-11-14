import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getup/services/storage_service.dart';
import 'package:getup/models/alarm_model.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    late StorageService service;

    setUp(() {
      service = StorageService();
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('loadAlarms returns empty list when no data', () async {
      final alarms = await service.loadAlarms();
      expect(alarms, isEmpty);
    });

    test('saveAlarms writes JSON and loadAlarms reads it back', () async {
      final now = DateTime.now().toUtc();
      final alarmsToSave = <AlarmModel>[
        AlarmModel(
          id: 1,
          scheduledTime: now,
          isEnabled: true,
          shakeIntensity: ShakeIntensity.strong,
          brightnessThreshold: BrightnessThreshold.low,
          audioPath: 'assets/marimba.mp3',
        ),
        AlarmModel(
          id: 2,
          scheduledTime: now.add(const Duration(minutes: 5)),
          isEnabled: false,
          shakeIntensity: ShakeIntensity.light,
          brightnessThreshold: BrightnessThreshold.high,
          audioPath: 'assets/beep.mp3',
        ),
      ];

      await service.saveAlarms(alarmsToSave);

      // Verify raw JSON stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('alarms');
      expect(stored, isNotNull);

      final decoded = json.decode(stored!) as List<dynamic>;
      expect(decoded, hasLength(2));
      expect(decoded.first['id'], 1);
      expect(decoded.first['soundPath'], 'assets/marimba.mp3');

      // Verify loadAlarms reconstructs AlarmModel objects correctly
      final loaded = await service.loadAlarms();
      expect(loaded.length, 2);

      expect(loaded[0].id, 1);
      expect(loaded[0].scheduledTime.toUtc(), now);
      expect(loaded[0].isEnabled, true);
      expect(loaded[0].shakeIntensity, ShakeIntensity.strong);
      expect(loaded[0].brightnessThreshold, BrightnessThreshold.low);
      expect(loaded[0].audioPath, 'assets/marimba.mp3');

      expect(loaded[1].id, 2);
      expect(
        loaded[1].scheduledTime.toUtc(),
        now.add(const Duration(minutes: 5)),
      );
      expect(loaded[1].isEnabled, false);
      expect(loaded[1].shakeIntensity, ShakeIntensity.light);
      expect(loaded[1].brightnessThreshold, BrightnessThreshold.high);
      expect(loaded[1].audioPath, 'assets/beep.mp3');
    });

    test('loadAlarms handles corrupted JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarms', 'invalid json {{{');

      expect(() => service.loadAlarms(), throwsFormatException);
    });

    test('loadAlarms handles missing required fields', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarms', '[{"id": 1}]');

      expect(() => service.loadAlarms(), throwsA(isA<TypeError>()));
    });
  });
}
