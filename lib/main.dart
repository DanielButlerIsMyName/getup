import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await NotificationService().initialize();
  await _requestPermissions();
  runApp(const MyApp());
}

  Future<void> _requestPermissions() async {
    await Permission.scheduleExactAlarm.request();
    await Permission.ignoreBatteryOptimizations.request();
    await Permission.notification.request();
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Alarm Clock',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
    }
  }