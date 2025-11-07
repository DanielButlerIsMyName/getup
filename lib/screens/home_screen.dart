import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/alarm_manager_service.dart';
import '../services/light_sensor_service.dart';
import 'create_alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final AlarmManagerService _alarmManager = AlarmManagerService();
  List<AlarmModel> _alarms = [];

  // Sensor data
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;
  double _lightLevel = 0.0;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<double>? _lightSubscription;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _startSensorListening();
  }

  void _startSensorListening() {
    // Listen to accelerometer using new API
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;
      });
    });

    // Real light sensor using platform channel
    final lightSensorService = LightSensorService();
    lightSensorService.startListening();

    _lightSubscription = lightSensorService.getLightSensorStream().listen(
      (double lux) {
        setState(() {
          _lightLevel = lux;
        });
      },
      onError: (error) {
        debugPrint('Light sensor error: $error');
        // Fallback to simulated light if sensor is not available
        setState(() {
          _lightLevel = 0.0;
        });
      },
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _lightSubscription?.cancel();
    LightSensorService().stopListening();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    final alarms = await _storageService.loadAlarms();
    setState(() {
      _alarms = alarms;
    });
  }

  Future<void> _deleteAlarm(int id) async {
    await _alarmManager.cancelAlarm(id);
    setState(() {
      _alarms.removeWhere((alarm) => alarm.id == id);
    });
    await _storageService.saveAlarms(_alarms);
  }

  Future<void> _testNotification() async {
    debugPrint('🧪 Testing notification...');
    await _notificationService.showAlarmNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    }
  }

  Future<void> _testShortAlarm() async {
    debugPrint('🧪 Setting 10 second test alarm...');
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await _alarmManager.scheduleAlarm(9999, testTime, requireShake: false, requireLight: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test alarm in 10 seconds!')),
      );
    }
  }

  Widget _buildSensorValue(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _testNotification,
            tooltip: 'Test Notification',
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _testShortAlarm,
            tooltip: 'Test 10s Alarm',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sensor displays
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sensors, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Sensor Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Accelerometer display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.rotate_right, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Accelerometer',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSensorValue('X', _accelerometerX, Colors.red),
                            _buildSensorValue('Y', _accelerometerY, Colors.green),
                            _buildSensorValue('Z', _accelerometerZ, Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Magnitude: ${sqrt(_accelerometerX * _accelerometerX + _accelerometerY * _accelerometerY + _accelerometerZ * _accelerometerZ).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Light sensor display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.light_mode, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'Light Sensor',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _lightLevel > 100
                                ? Colors.amber.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_lightLevel.toStringAsFixed(1)} lux',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _lightLevel > 100 ? Colors.amber[900] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Alarm list
          Expanded(
            child: _alarms.isEmpty
                ? const Center(
                    child: Text('No alarms set'),
                  )
                : ListView.builder(
                    itemCount: _alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = _alarms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            '${alarm.scheduledTime.hour.toString().padLeft(2, '0')}:${alarm.scheduledTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (alarm.requireShake)
                                const Text('🤝 Shake to dismiss'),
                              if (alarm.requireLight)
                                const Text('💡 Light to dismiss'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAlarm(alarm.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAlarmScreen(),
            ),
          );
          if (result != null) {
            _loadAlarms();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}