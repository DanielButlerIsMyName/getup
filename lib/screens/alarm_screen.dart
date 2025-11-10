import 'package:flutter/material.dart';
import 'package:getup/services/alarm_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import '../services/light_detector_service.dart';
import '../services/shake_detector_service.dart';
import '../models/alarm_model.dart';

class AlarmScreen extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmScreen({super.key, required this.alarm});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  final LightDetectorService _lightDetector = LightDetectorService();
  final AlarmManagerService _alarmService = AlarmManagerService();

  StreamSubscription<double>? _lightSubscription;

  bool _shakeRequirementMet = false;
  bool _lightRequirementMet = false;
  double _currentLightLevel = 0.0;
  int _shakeCount = 0;
  int _requiredShakes = 0;

  @override
  void initState() {
    super.initState();
    _setupAlarm();
  }

  Future<void> _setupAlarm() async {
    // Keep screen on
    WakelockPlus.enable();

    // Setup shake requirement
    _requiredShakes = 30;
    if (_requiredShakes > 0) {
      final shakeThreshold = _getShakeThreshold(widget.alarm.shakeIntensity);
      _shakeDetector.startListening(_onShake, threshold: shakeThreshold);
    } else {
      _shakeRequirementMet = true;
    }

    // Setup light requirement
    final lightThreshold = _getLightThreshold(widget.alarm.brightnessThreshold);
    if (lightThreshold > 0) {
      _lightDetector.startMonitoring();
      _lightSubscription = _lightDetector.getLightStream().listen((lux) {
        setState(() {
          _currentLightLevel = lux;
          _lightRequirementMet = lux >= lightThreshold;
        });
      });
    } else {
      _lightRequirementMet = true;
    }
  }

  double _getShakeThreshold(ShakeIntensity intensity) {
    switch (intensity) {
      case ShakeIntensity.light:
        return 50.0;
      case ShakeIntensity.medium:
        return 100.0;
      case ShakeIntensity.strong:
        return 150.0;
    }
  }

  int _getLightThreshold(BrightnessThreshold threshold) {
    switch (threshold) {
      case BrightnessThreshold.low:
        return 300;
      case BrightnessThreshold.normal:
        return 400;
      case BrightnessThreshold.high:
        return 500;
    }
  }

  void _onShake() {
    setState(() {
      _shakeCount++;
      if (_shakeCount >= _requiredShakes) {
        _shakeRequirementMet = true;
      }
    });
  }

  Future<void> _dismissAlarm() async {
    if (!_canDismiss) return;

    _shakeDetector.stopListening();
    _lightDetector.stopMonitoring();
    await _lightSubscription?.cancel();
    WakelockPlus.disable();

    _alarmService.cancelAlarm(widget.alarm.id);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  bool get _canDismiss => _shakeRequirementMet && _lightRequirementMet;

  @override
  void dispose() {
    _shakeDetector.stopListening();
    _lightDetector.stopMonitoring();
    _lightDetector.dispose();
    _lightSubscription?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_requiredShakes > 0)
                        _RequirementCard(
                          icon: Icons.vibration,
                          title: 'Shake Phone',
                          subtitle: '$_shakeCount / $_requiredShakes shakes',
                          isCompleted: _shakeRequirementMet,
                          progress: _shakeCount / _requiredShakes,
                        ),

                      if (_requiredShakes > 0 &&
                          _getLightThreshold(widget.alarm.brightnessThreshold) >
                              0)
                        const SizedBox(height: 16),

                      // Light requirement
                      if (_getLightThreshold(widget.alarm.brightnessThreshold) >
                          0)
                        _RequirementCard(
                          icon: Icons.light_mode,
                          title: 'Turn on Light',
                          subtitle:
                              '${_currentLightLevel.toStringAsFixed(0)} / ${_getLightThreshold(widget.alarm.brightnessThreshold)} lux',
                          isCompleted: _lightRequirementMet,
                          progress:
                              (_currentLightLevel /
                                      _getLightThreshold(
                                        widget.alarm.brightnessThreshold,
                                      ))
                                  .clamp(0.0, 1.0),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _canDismiss ? _dismissAlarm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canDismiss
                          ? Colors.green
                          : Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final double progress;

  const _RequirementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: isCompleted ? Colors.green : Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Colors.blue,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
        ],
      ),
    );
  }
}
