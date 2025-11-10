import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/services/light_detector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LightDetectorService', () {
    const MethodChannel methodChannel = MethodChannel('com.getup.alarm/sensors');

    late List<MethodCall> calls;
    late LightDetectorService service;

    setUp(() {
      calls = <MethodCall>[];
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      // Capture platform method calls
      messenger.setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        calls.add(call);
        // no return value expected for our methods
        return null;
      });

      service = LightDetectorService();
    });

    tearDown(() {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      // Remove mock to avoid test cross-talk
      messenger.setMockMethodCallHandler(methodChannel, null);
      service.dispose();
    });

    test('startMonitoring invokes startLightSensor', () async {
      service.startMonitoring();

      // Allow microtask queue to process the platform invocation
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(calls, isNotEmpty);
      expect(calls.first.method, 'startLightSensor');
    });

    test('stopMonitoring invokes stopLightSensor and resets detection state', () async {
      service.startMonitoring();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      calls.clear();

      service.stopMonitoring();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(calls, hasLength(1));
      expect(calls.single.method, 'stopLightSensor');

      // State should reset to false after stopping
      final isDetected = await service.checkLightLevel();
      expect(isDetected, isFalse);
    });

    test('getLightStream is broadcast stream', () async {
      final stream = service.getLightStream();

      // Listen twice to ensure broadcast behavior
      final s1 = stream.listen((_) {});
      final s2 = stream.listen((_) {});

      await s1.cancel();
      await s2.cancel();
    });
  });
}
