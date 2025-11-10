import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/services/light_sensor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LightSensorService', () {
    const MethodChannel methodChannel = MethodChannel('com.getup.alarm/sensors');
    const String eventChannelName = 'com.getup.alarm/light_sensor';
    const StandardMethodCodec codec = StandardMethodCodec();

    late List<MethodCall> methodCalls;
    late LightSensorService service;

    setUp(() {
      methodCalls = <MethodCall>[];
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      // Mock MethodChannel invocations
      messenger.setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        methodCalls.add(call);
        return null;
      });

      // Set a default mock for EventChannel to avoid platform errors when listening
      messenger.setMockMessageHandler(eventChannelName, (ByteData? message) async {
        // Decode the incoming method call from Dart side (listen/cancel)
        final MethodCall call = codec.decodeMethodCall(message);
        if (call.method == 'listen') {
          // When Dart starts listening, emit one event (numeric) then close the stream
          // Send a numeric event (int) which should map to double in service
          await messenger.handlePlatformMessage(
            eventChannelName,
            codec.encodeSuccessEnvelope(42),
            (_) {},
          );
          // Close the stream by sending null
          await messenger.handlePlatformMessage(eventChannelName, null, (_) {});
        }
        return null; // no direct reply required
      });

      service = LightSensorService();
    });

    tearDown(() async {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(methodChannel, null);
      messenger.setMockMessageHandler(eventChannelName, null);
    });

    test('startListening invokes startLightSensor', () async {
      await service.startListening();

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'startLightSensor');
    });

    test('stopListening invokes stopLightSensor', () async {
      await service.stopListening();

      expect(methodCalls, isNotEmpty);
      expect(methodCalls.first.method, 'stopLightSensor');
    });

    test('getLightSensorStream returns memoized broadcast stream and maps to double', () async {
      final streamA = service.getLightSensorStream();
      final streamB = service.getLightSensorStream();

      // Memoization: same instance
      expect(identical(streamA, streamB), isTrue);

      // Collect first (and only) emitted value from mocked EventChannel
      final values = <double>[];
      final sub = streamA.listen(values.add);
      await sub.asFuture<void>(); // completes when stream closes (we emit null)

      expect(values, isNotEmpty);
      expect(values.single, 42.0); // mapped from int 42 to double 42.0
    });
  });
}
