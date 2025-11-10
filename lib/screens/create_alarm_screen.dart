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
  ShakeIntensity _shakeIntensity = ShakeIntensity.medium;
  BrightnessThreshold _brightnessThreshold = BrightnessThreshold.normal;
  String _selectedSound = 'assets/marimba.mp3';

  static const Map<String, String> _soundOptions = {
    'Marimba': 'assets/marimba.mp3',
    'Beep': 'assets/beep.mp3',
    'Classic': 'assets/classic.mp3',
  };

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

    final alarms = await _storageService.loadAlarms();
    final newId = alarms.isEmpty ? 1 : alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;

    final alarm = AlarmModel(
      id: newId,
      scheduledTime: scheduledTime,
      shakeIntensity: _shakeIntensity,
      brightnessThreshold: _brightnessThreshold,
      audioPath: _selectedSound,
    );

    alarms.add(alarm);
    await _storageService.saveAlarms(alarms);

    await _alarmManager.scheduleAlarm(
      alarm
    );

    debugPrint('Alarm saved with ID: $newId');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm set for ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: availableHeight),
          child: IntrinsicHeight(
            child: Padding(
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
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ShakeIntensity>(
                    initialValue: _shakeIntensity,
                    decoration: const InputDecoration(labelText: 'Shake Intensity'),
                    items: ShakeIntensity.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name[0].toUpperCase() + e.name.substring(1)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _shakeIntensity = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BrightnessThreshold>(
                    initialValue: _brightnessThreshold,
                    decoration: const InputDecoration(labelText: 'Brightness Threshold'),
                    items: BrightnessThreshold.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name[0].toUpperCase() + e.name.substring(1)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _brightnessThreshold = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSound,
                    decoration: const InputDecoration(labelText: 'Sound'),
                    items: _soundOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSound = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: Container()),
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
          ),
        ),
      ),
    );
  }
}