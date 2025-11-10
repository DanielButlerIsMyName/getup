import 'package:flutter/material.dart';
import 'dart:async';
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

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final alarms = await _storageService.loadAlarms();
    alarms.sort((a, b) => b.id.compareTo(a.id));
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

  Future<void> _toggleAlarm(AlarmModel alarm, bool enabled) async {
    DateTime scheduledTime = alarm.scheduledTime;

    if (enabled && scheduledTime.isBefore(DateTime.now())) {
      final now = DateTime.now();
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.scheduledTime.hour,
        alarm.scheduledTime.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    final updatedAlarm = AlarmModel(
      id: alarm.id,
      scheduledTime: scheduledTime,
      isEnabled: enabled,
      shakeIntensity: alarm.shakeIntensity,
      brightnessThreshold: alarm.brightnessThreshold,
      audioPath: alarm.audioPath,
    );

    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      setState(() {
        _alarms[index] = updatedAlarm;
      });
      await _storageService.saveAlarms(_alarms);

      if (enabled) {
        await _alarmManager.scheduleAlarm(updatedAlarm);
      } else {
        await _alarmManager.cancelAlarm(alarm.id);
      }
    }
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
          Expanded(
            child: _alarms.isEmpty
                ? const Center(child: Text('No alarms set'))
                : ListView.builder(
                    itemCount: _alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = _alarms[index];
                      return Dismissible(
                        key: Key(alarm.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteAlarm(alarm.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateAlarmScreen(alarm: alarm),
                                ),
                              );
                              if (result != null) {
                                _loadAlarms();
                              }
                            },
                            title: Text(
                              '${alarm.scheduledTime.hour.toString().padLeft(2, '0')}:${alarm.scheduledTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: alarm.isEnabled ? null : Colors.grey,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Shake intensity: ${alarm.shakeIntensity.displayName}",
                                ),
                                Text(
                                  "Brightness Threshold: ${alarm.brightnessThreshold.displayName}",
                                ),
                                Text(
                                  "Alarm sound: ${getDisplayNameForPath(alarm.audioPath)}",
                                ),
                              ],
                            ),
                            trailing: Switch(
                              value: alarm.isEnabled,
                              onChanged: (value) => _toggleAlarm(alarm, value),
                            ),
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
            MaterialPageRoute(builder: (context) => const CreateAlarmScreen()),
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
