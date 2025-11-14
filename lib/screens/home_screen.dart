import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getup/screens/alarm_screen.dart';

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
    setState(() => _alarms = alarms);
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
    if (result != null) _loadAlarms();
  }

  DateTime _calculateNextOccurrence(DateTime scheduledTime) {
    final now = DateTime.now();
    var nextTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    return nextTime;
  }

  Future<void> _toggleAlarm(AlarmModel alarm, bool enabled) async {
    final scheduledTime =
        enabled && alarm.scheduledTime.isBefore(DateTime.now())
        ? _calculateNextOccurrence(alarm.scheduledTime)
        : alarm.scheduledTime;

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
      setState(() => _alarms[index] = updatedAlarm);
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
    var difference = alarm.scheduledTime.difference(now);

    if (difference.isNegative) {
      difference = alarm.scheduledTime
          .add(const Duration(days: 1))
          .difference(now);
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (hours > 0) return 'in ${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return 'in ${minutes}m ${seconds}s';
    return 'in ${seconds}s';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _navigateToCreateOrEdit(AlarmModel? alarm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAlarmScreen(alarm: alarm)),
    );
    if (result != null) _loadAlarms();
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
                            onTap: () => _navigateToCreateOrEdit(alarm),
                            leading: Icon(
                              Icons.alarm,
                              color: alarm.isEnabled ? null : Colors.grey,
                            ),
                            title: Text(
                              _formatTime(alarm.scheduledTime),
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
        onPressed: () => _navigateToCreateOrEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
