import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testAlarmJson = {
    'id': 1,
    'scheduledTime': DateTime.now().toIso8601String(),
    'isEnabled': true,
    'shakeIntensity': 'medium',
    'brightnessThreshold': 'normal',
    'soundPath': 'assets/marimba.mp3',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('HomeScreen shows empty state when no alarms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No alarms set'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('HomeScreen displays alarms from storage', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'alarms': json.encode([testAlarmJson]),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('HomeScreen updates time countdown every second', (
    WidgetTester tester,
  ) async {
    final futureTime = DateTime.now().add(const Duration(minutes: 5));
    final futureAlarmJson = {
      ...testAlarmJson,
      'scheduledTime': futureTime.toIso8601String(),
    };

    SharedPreferences.setMockInitialValues({
      'alarms': json.encode([futureAlarmJson]),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final initialCountdown = find.textContaining('in');
    expect(initialCountdown, findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(initialCountdown, findsOneWidget);
  });

  testWidgets('HomeScreen shows empty state when JSON is corrupted', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'alarms': 'invalid json {{{'});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No alarms set'), findsOneWidget);
  });

  testWidgets('HomeScreen shows empty state when alarm has missing fields', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'alarms': json.encode([
        {'id': 1},
      ]),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No alarms set'), findsOneWidget);
  });
}
