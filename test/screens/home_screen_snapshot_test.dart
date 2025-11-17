import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('HomeScreen without alarms matches golden file', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('golden/home_screen_empty.png'),
    );
  });

  testWidgets('HomeScreen with 2 alarms matches golden file', (
    WidgetTester tester,
  ) async {
    final alarmJson = [
      {
        'id': 1,
        'scheduledTime': DateTime.now().toIso8601String(),
        'isEnabled': false,
        'shakeIntensity': 'medium',
        'brightnessThreshold': 'normal',
        'soundPath': 'assets/classic.mp3',
      },
      {
        'id': 2,
        'scheduledTime': DateTime(2024, 1, 1, 7, 30).toIso8601String(),
        'isEnabled': true,
        'shakeIntensity': 'light',
        'brightnessThreshold': 'low',
        'soundPath': 'assets/beep.mp3',
      },
    ];

    SharedPreferences.setMockInitialValues({'alarms': json.encode(alarmJson)});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('golden/home_screen_with_alarms.png'),
    );
  });
}
