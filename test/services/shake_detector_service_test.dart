import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:getup/services/shake_detector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShakeDetectorService', () {
    late ShakeDetectorService service;
    late StreamController<AccelerometerEvent> controller;
    late List<bool> shakes;

    setUp(() {
      controller = StreamController<AccelerometerEvent>();
      service = ShakeDetectorService(accelerometerStream: controller.stream);
      shakes = <bool>[];
    });

    tearDown(() {
      service.stopListening();
      controller.close();
    });

    test('calls onShake when magnitude exceeds threshold', () async {
      // magnitude sqrt(10^2 + 10^2 + 10^2) ~ 17.32 > 15
      final completer = Completer<void>();
      service.startListening(() {
        shakes.add(true);
        if (!completer.isCompleted) completer.complete();
      });

      controller.add(AccelerometerEvent(10, 10, 10, DateTime.now()));

      // Wait until stream closes or we detect a shake
      await completer.future.timeout(const Duration(seconds: 2));

      expect(shakes.length, 1);
    });

    test('does not call onShake for sub-threshold magnitude', () async {
      // magnitude sqrt(5^2 + 5^2 + 5^2) ~ 8.66 < 15
      service.startListening(() {
        shakes.add(true);
      });

      controller.add(AccelerometerEvent(5, 5, 5, DateTime.now()));

      // Give time for events to process and stream to close
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(shakes, isEmpty);
    });

    test('stopListening cancels subscription; no callbacks after stop', () async {
      service.startListening(() {
        shakes.add(true);
      });

      // Immediately stop before the event fires
      service.stopListening();

      // Wait long enough that, if not cancelled, a shake would have been recorded
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        controller.add(AccelerometerEvent(10, 10, 10, DateTime.now()));
      });
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(shakes, isEmpty);
    });
  });
}
