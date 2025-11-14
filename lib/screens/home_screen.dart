import 'package:flutter/material.dart';
import 'package:getup/screens/alarm_screen.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
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
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
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

  Future<void> _navigateToAlarm() async {
    final alarmModel = AlarmModel(
      id: 0,
      scheduledTime: DateTime.now(),
      isEnabled: true,
      shakeIntensity: ShakeIntensity.medium,
      brightnessThreshold: BrightnessThreshold.normal,
      audioPath: 'assets/marimba.mp3',
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmScreen(alarm: alarmModel)),
    );
    if (result != null) {
      _loadAlarms();
    }
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

  String _getTimeUntilAlarm(AlarmModel alarm) {
    final now = DateTime.now();
    final scheduledTime = alarm.scheduledTime;
    Duration difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      difference = scheduledTime.add(const Duration(days: 1)).difference(now);
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (hours > 0) {
      return 'in ${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return 'in ${minutes}m ${seconds}s';
    } else {
      return 'in ${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: _navigateToAlarm,
          ),
        ],
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
                            leading: Icon(
                              Icons.alarm,
                              color: alarm.isEnabled ? null : Colors.grey,
                            ),
                            title: Text(
                              '${alarm.scheduledTime.hour.toString().padLeft(2, '0')}:${alarm.scheduledTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: alarm.isEnabled ? null : Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              _getTimeUntilAlarm(alarm),
                              style: TextStyle(
                                color: alarm.isEnabled ? null : Colors.grey,
                              ),
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
