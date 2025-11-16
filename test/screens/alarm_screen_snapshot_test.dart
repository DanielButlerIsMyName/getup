import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/models/alarm_model.dart';
import 'package:getup/screens/alarm_screen.dart';

void main() {
  testWidgets('AlarmScreen matches golden file', (WidgetTester tester) async {
    final alarmModel = AlarmModel(
      id: 0,
      scheduledTime: DateTime.now(),
      isEnabled: true,
      shakeIntensity: ShakeIntensity.medium,
      brightnessThreshold: BrightnessThreshold.normal,
      audioPath: 'assets/marimba.mp3',
    );

    await tester.pumpWidget(
      MaterialApp(home: AlarmScreen(alarm: alarmModel, enableSensors: false)),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AlarmScreen),
      matchesGoldenFile('golden/alarm_screen_incomplete.png'),
    );
  });
}
