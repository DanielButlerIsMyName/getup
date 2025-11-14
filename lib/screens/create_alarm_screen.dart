import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';

class CreateAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const CreateAlarmScreen({super.key, this.alarm});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  final StorageService _storageService = StorageService();
  final AlarmManagerService _alarmManager = AlarmManagerService();

  late TimeOfDay _selectedTime;
  late ShakeIntensity _shakeIntensity;
  late BrightnessThreshold _brightnessThreshold;
  late String _selectedSound;

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _selectedTime = alarm != null
        ? TimeOfDay(hour: alarm.scheduledTime.hour, minute: alarm.scheduledTime.minute)
        : TimeOfDay.now();
    _shakeIntensity = alarm?.shakeIntensity ?? ShakeIntensity.medium;
    _brightnessThreshold = alarm?.brightnessThreshold ?? BrightnessThreshold.normal;
    _selectedSound = alarm?.audioPath ?? 'assets/marimba.mp3';
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime _createScheduledTime() {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    return scheduledTime;
  }

  int _generateNewId(List<AlarmModel> alarms) {
    return alarms.isEmpty
        ? 1
        : alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  AlarmModel _createAlarmModel(DateTime scheduledTime, int id, bool isEnabled) {
    return AlarmModel(
      id: id,
      scheduledTime: scheduledTime,
      isEnabled: isEnabled,
      shakeIntensity: _shakeIntensity,
      brightnessThreshold: _brightnessThreshold,
      audioPath: _selectedSound,
    );
  }

  Future<void> _saveAlarm() async {
    final scheduledTime = _createScheduledTime();
    final alarms = await _storageService.loadAlarms();

    if (widget.alarm != null) {
      final index = alarms.indexWhere((a) => a.id == widget.alarm!.id);
      if (index != -1) {
        alarms[index] = _createAlarmModel(
          scheduledTime,
          widget.alarm!.id,
          widget.alarm!.isEnabled,
        );
      }
    } else {
      alarms.add(_createAlarmModel(scheduledTime, _generateNewId(alarms), true));
    }

    await _storageService.saveAlarms(alarms);
    await _alarmManager.scheduleAlarm(
      alarms.firstWhere((a) => a.scheduledTime == scheduledTime),
    );

    if (mounted) Navigator.pop(context, true);
  }

  String _capitalize(String text) => text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    final availableHeight =
        MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Edit Alarm' : 'Create Alarm'),
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
                            const Text('Time', style: TextStyle(fontSize: 16)),
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
                  DropdownButtonFormField<ShakeIntensity>(
                    initialValue: _shakeIntensity,
                    decoration: const InputDecoration(
                      labelText: 'Shake Intensity',
                    ),
                    items: ShakeIntensity.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(_capitalize(e.name)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _shakeIntensity = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BrightnessThreshold>(
                    initialValue: _brightnessThreshold,
                    decoration: const InputDecoration(
                      labelText: 'Brightness Threshold',
                    ),
                    items: BrightnessThreshold.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(_capitalize(e.name)),
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
                    items: soundOptions.entries.map((entry) {
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
          ),
        ),
      ),
    );
  }
}
