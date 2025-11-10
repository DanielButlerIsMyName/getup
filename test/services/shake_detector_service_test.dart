import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/services/shake_detector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShakeDetectorService', () {
    const String accelChannel = 'plugins.flutter.io/sensors/accelerometer';
    const StandardMethodCodec codec = StandardMethodCodec();

    late ShakeDetectorService service;
    late List<bool> shakes;

    setUp(() {
      service = ShakeDetectorService();
      shakes = <bool>[];

      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      // Default: no-op handler; each test may override by setting another handler
      messenger.setMockMessageHandler(accelChannel, (ByteData? message) async {
        // We leave it inert here; each test sets its own emission behavior
        return null;
      });
    });

    tearDown(() {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMessageHandler(accelChannel, null);
      service.stopListening();
    });

    Future<void> _emitAccelerometerEvents(List<List<double>> xyzTriples) async {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      // When the Dart side starts listening, send the provided events then close.
      messenger.setMockMessageHandler(accelChannel, (ByteData? message) async {
        final MethodCall call = codec.decodeMethodCall(message);
        if (call.method == 'listen') {
          for (final triple in xyzTriples) {
            await messenger.handlePlatformMessage(
              accelChannel,
              codec.encodeSuccessEnvelope(triple),
              (_) {},
            );
          }
          // Close the stream by sending null
          await messenger.handlePlatformMessage(accelChannel, null, (_) {});
        }
        return null;
      });
    }

    test('calls onShake when magnitude exceeds threshold', () async {
      // magnitude sqrt(10^2 + 10^2 + 10^2) ~ 17.32 > 15
      await _emitAccelerometerEvents(<List<double>>[
        <double>[10, 10, 10],
      ]);

      final completer = Completer<void>();
      service.startListening(() {
        shakes.add(true);
        if (!completer.isCompleted) completer.complete();
      });

      // Wait until stream closes or we detect a shake
      await completer.future.timeout(const Duration(seconds: 2));

      expect(shakes.length, 1);
    });

    test('does not call onShake for sub-threshold magnitude', () async {
      // magnitude sqrt(5^2 + 5^2 + 5^2) ~ 8.66 < 15
      await _emitAccelerometerEvents(<List<double>>[
        <double>[5, 5, 5],
      ]);

      service.startListening(() {
        shakes.add(true);
      });

      // Give time for events to process and stream to close
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(shakes, isEmpty);
    });

    test('stopListening cancels subscription; no callbacks after stop', () async {
      // Prepare handler that would emit an over-threshold event after a brief delay
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMessageHandler(accelChannel, (ByteData? message) async {
        final MethodCall call = codec.decodeMethodCall(message);
        if (call.method == 'listen') {
          // Emit after a short delay to allow stopListening to run first
          Future<void>.delayed(const Duration(milliseconds: 50), () async {
            await messenger.handlePlatformMessage(
              accelChannel,
              codec.encodeSuccessEnvelope(<double>[10, 10, 10]),
              (_) {},
            );
            await messenger.handlePlatformMessage(accelChannel, null, (_) {});
          });
        }
        return null;
      });

      service.startListening(() {
        shakes.add(true);
      });

      // Immediately stop before the event fires
      service.stopListening();

      // Wait long enough that, if not cancelled, a shake would have been recorded
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(shakes, isEmpty);
    });
  });
}
