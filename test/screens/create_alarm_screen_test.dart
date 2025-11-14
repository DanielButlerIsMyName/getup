import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/screens/create_alarm_screen.dart';

void main() {
  testWidgets('CreateAlarmScreen shows Save Alarm button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateAlarmScreen()));

    await tester.pump();

    expect(find.text('Save Alarm'), findsOneWidget);
  });

  testWidgets('CreateAlarmScreen opens time picker when tapping time area', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateAlarmScreen()));

    await tester.pump();

    // Tap the time selector (InkWell around the time display)
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
  });
}
