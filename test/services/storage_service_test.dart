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
        AlarmModel(id: 1, scheduledTime: now, isEnabled: true, requireShake: true, requireLight: false, soundPath: 'a.mp3'),
        AlarmModel(id: 2, scheduledTime: now.add(const Duration(minutes: 5)), isEnabled: false, requireShake: false, requireLight: true, soundPath: 'b.mp3'),
      ];

      await service.saveAlarms(alarmsToSave);

      // Verify raw JSON stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('alarms');
      expect(stored, isNotNull);

      final decoded = json.decode(stored!) as List<dynamic>;
      expect(decoded, hasLength(2));
      expect(decoded.first['id'], 1);
      expect(decoded.first['soundPath'], 'a.mp3');

      // Verify loadAlarms reconstructs AlarmModel objects correctly
      final loaded = await service.loadAlarms();
      expect(loaded.length, 2);

      expect(loaded[0].id, 1);
      expect(loaded[0].scheduledTime.toUtc(), now);
      expect(loaded[0].isEnabled, true);
      expect(loaded[0].requireShake, true);
      expect(loaded[0].requireLight, false);
      expect(loaded[0].soundPath, 'a.mp3');

      expect(loaded[1].id, 2);
      expect(loaded[1].scheduledTime.toUtc(), now.add(const Duration(minutes: 5)));
      expect(loaded[1].isEnabled, false);
      expect(loaded[1].requireShake, false);
      expect(loaded[1].requireLight, true);
      expect(loaded[1].soundPath, 'b.mp3');
    });
  });
}
