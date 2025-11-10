import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';

class CreateAlarmScreen extends StatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  final StorageService _storageService = StorageService();
  final AlarmManagerService _alarmManager = AlarmManagerService();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _requireShake = false;
  bool _requireLight = false;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAlarm() async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    debugPrint('Creating alarm for: $scheduledTime');
    debugPrint('Current time: $now');
    debugPrint('Time until alarm: ${scheduledTime.difference(now)}');

    final alarms = await _storageService.loadAlarms();
    final newId = alarms.isEmpty ? 1 : alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;

    final alarm = AlarmModel(
      id: newId,
      scheduledTime: scheduledTime,
      requireShake: _requireShake,
      requireLight: _requireLight,
    );

    alarms.add(alarm);
    await _storageService.saveAlarms(alarms);
    await _alarmManager.scheduleAlarm(
      alarm.id,
      scheduledTime,
      requireShake: _requireShake,
      requireLight: _requireLight,
    );

    debugPrint('Alarm saved with ID: $newId');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm set for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: InkWell(
                onTap: _selectTime,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Require Shake to Dismiss'),
              subtitle: const Text('Shake phone to turn off alarm'),
              value: _requireShake,
              onChanged: (value) {
                setState(() {
                  _requireShake = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Require Light to Dismiss'),
              subtitle: const Text('Expose phone to light'),
              value: _requireLight,
              onChanged: (value) {
                setState(() {
                  _requireLight = value;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveAlarm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Save Alarm',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}