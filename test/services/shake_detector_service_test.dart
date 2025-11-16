import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:getup/services/shake_detector_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShakeDetectorService', () {
    late ShakeDetectorService service;
    late StreamController<UserAccelerometerEvent> controller;
    late List<bool> shakes;

    setUp(() {
      controller = StreamController<UserAccelerometerEvent>();
      service = ShakeDetectorService(accelerometerStream: controller.stream);
      shakes = <bool>[];
    });

    tearDown(() {
      service.stopListening();
      controller.close();
    });

    test('stopListening cancels subscription; no callbacks after stop', () async {
      service.startListening(() {
        shakes.add(true);
      });

      // Immediately stop before the event fires
      service.stopListening();

      // Wait long enough that, if not cancelled, a shake would have been recorded
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        controller.add(UserAccelerometerEvent(10, 10, 10, DateTime.now()));
      });
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(shakes, isEmpty);
    });
  });
}
