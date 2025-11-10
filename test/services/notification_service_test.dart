import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getup/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    // This is the standard channel used by flutter_local_notifications
    const MethodChannel pluginChannel = MethodChannel('dexterous.com/flutter/local_notifications');

    late List<MethodCall> calls;
    late NotificationService service;

    setUp(() {
      calls = <MethodCall>[];
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      messenger.setMockMethodCallHandler(pluginChannel, (MethodCall call) async {
        calls.add(call);
        return null;
      });

      service = NotificationService();
    });

    tearDown(() {
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(pluginChannel, null);
    });

    test('initialize calls plugin initialize and creates channel', () async {
      await service.initialize();

      // Expect at least initialize and createNotificationChannel calls
      final methodNames = calls.map((c) => c.method).toList();
      expect(methodNames, contains('initialize'));
      expect(methodNames, contains('createNotificationChannel'));
    });

    test('showAlarmNotification calls plugin show', () async {
      // Ensure plugin has been initialized to avoid plugin-side guards
      await service.initialize();
      calls.clear();

      await service.showAlarmNotification();

      final methodNames = calls.map((c) => c.method).toList();
      expect(methodNames, contains('show'));
    });
  });
}
