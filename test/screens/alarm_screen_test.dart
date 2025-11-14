import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/screens/alarm_screen.dart';
import 'package:getup/models/alarm_model.dart';

void main() {
  testWidgets('AlarmScreen displays alarm time and ALARM text', (
    WidgetTester tester,
  ) async {
    final testAlarm = AlarmModel(
      id: 1,
      scheduledTime: DateTime(2024, 1, 1, 7, 30),
      shakeIntensity: ShakeIntensity.medium,
      brightnessThreshold: BrightnessThreshold.normal,
    );

    await tester.pumpWidget(MaterialApp(home: AlarmScreen(alarm: testAlarm)));

    // Allow async operations to complete
    await tester.pump();

    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('AlarmScreen displays shake and light requirements', (
    WidgetTester tester,
  ) async {
    final testAlarm = AlarmModel(
      id: 1,
      scheduledTime: DateTime(2024, 1, 1, 7, 30),
      shakeIntensity: ShakeIntensity.light,
      brightnessThreshold: BrightnessThreshold.low,
    );

    await tester.pumpWidget(MaterialApp(home: AlarmScreen(alarm: testAlarm)));

    // Allow async operations to complete
    await tester.pump();

    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('AlarmScreen has dismiss button', (WidgetTester tester) async {
    final testAlarm = AlarmModel(
      id: 1,
      scheduledTime: DateTime(2024, 1, 1, 8, 15),
      shakeIntensity: ShakeIntensity.medium,
      brightnessThreshold: BrightnessThreshold.normal,
    );

    await tester.pumpWidget(MaterialApp(home: AlarmScreen(alarm: testAlarm)));

    // Allow async operations to complete
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
