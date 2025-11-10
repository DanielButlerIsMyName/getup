import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/home_screen.dart';
import 'screens/alarm_screen.dart';
import 'models/alarm_model.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await _requestPermissions();
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  await Permission.scheduleExactAlarm.request();
  await Permission.ignoreBatteryOptimizations.request();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final StorageService _storageService = StorageService();
  int? _currentAlarmId;

  @override
  void initState() {
    super.initState();
    _listenToAlarms();
  }

  void _listenToAlarms() {
    Alarm.ringing.listen((alarmSet) async {
      if (alarmSet.alarms.isEmpty) {
        _currentAlarmId = null;
        return;
      }

      final alarmSettings = alarmSet.alarms.first;

      if (_currentAlarmId == alarmSettings.id) {
        return;
      }

      _currentAlarmId = alarmSettings.id;

      final alarms = await _storageService.loadAlarms();
      final matchingAlarm = alarms.firstWhere(
        (alarm) => alarm.id == alarmSettings.id,
        orElse: () => AlarmModel(
          id: alarmSettings.id,
          scheduledTime: alarmSettings.dateTime,
        ),
      );

      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmScreen(alarm: matchingAlarm),
          fullscreenDialog: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Alarm Clock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
