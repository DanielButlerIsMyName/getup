import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationApi {
  Future<void> initialize(InitializationSettings settings);
  Future<void> createAndroidChannel(AndroidNotificationChannel channel);
  Future<void> show(int id, String? title, String? body, NotificationDetails details);
}

class FlutterNotificationApi implements NotificationApi {
  final FlutterLocalNotificationsPlugin _plugin;

  FlutterNotificationApi({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize(InitializationSettings settings) {
    return _plugin.initialize(settings);
  }

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<void> show(int id, String? title, String? body, NotificationDetails details) {
    return _plugin.show(id, title, body, details);
  }
}


