import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import 'create_alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final AlarmManagerService _alarmManager = AlarmManagerService();
  List<AlarmModel> _alarms = [];

  StreamSubscription<double>? _lightSubscription;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
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