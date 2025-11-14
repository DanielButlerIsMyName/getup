import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/screens/create_alarm_screen.dart';

void main() {
  testWidgets('CreateAlarmScreen matches golden file', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateAlarmScreen()));

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CreateAlarmScreen),
      matchesGoldenFile('golden/create_alarm_screen.png'),
    );
  });
}
