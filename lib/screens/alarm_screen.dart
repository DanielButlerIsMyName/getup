import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getup/services/alarm_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../constants/alarm_constant.dart';
import '../models/alarm_model.dart';
import '../services/light_detector_service.dart';
import '../services/shake_detector_service.dart';

class AlarmScreen extends StatefulWidget {
  final AlarmModel alarm;
  final bool enableSensors;

  const AlarmScreen({
    super.key,
    required this.alarm,
    this.enableSensors = true,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  ShakeDetectorService? _shakeDetector;
  LightDetectorService? _lightDetector;
  final AlarmManagerService _alarmService = AlarmManagerService();

  StreamSubscription<double>? _lightSubscription;

  bool _shakeRequirementMet = false;
  bool _lightRequirementMet = false;
  double _currentLightLevel = 0.0;
  int _shakeCount = 0;
  int _requiredShakes = 0;
  int _lightThreshold = 0;

  @override
  void initState() {
    super.initState();
    _requiredShakes = _getRequiredShakes(widget.alarm.shakeIntensity);
    _lightThreshold = _getLightThreshold(widget.alarm.brightnessThreshold);
    if (widget.enableSensors) {
      WakelockPlus.enable();
      _setupSensors();
    }
  }

  void _setupSensors() {
    _shakeDetector = ShakeDetectorService();
    _lightDetector = LightDetectorService();

    _shakeRequirementMet = !_hasShakeRequirement;
    if (_hasShakeRequirement) {
      _shakeDetector?.startListening(
        _onShake,
        threshold: _getShakeThreshold(widget.alarm.shakeIntensity),
      );
    }

    _lightRequirementMet = !_hasLightRequirement;
    if (_hasLightRequirement) {
      _lightDetector?.startMonitoring();
      _lightSubscription = _lightDetector?.getLightStream().listen((lux) {
        setState(() {
          _currentLightLevel = lux;
          _lightRequirementMet = lux >= _lightThreshold;
        });
      });
    }
  }

  double _getShakeThreshold(ShakeIntensity intensity) => switch (intensity) {
    ShakeIntensity.light => AlarmConstants.shakeThresholdLight,
    ShakeIntensity.medium => AlarmConstants.shakeThresholdMedium,
    ShakeIntensity.strong => AlarmConstants.shakeThresholdStrong,
  };

  int _getLightThreshold(BrightnessThreshold threshold) => switch (threshold) {
    BrightnessThreshold.low => AlarmConstants.lightThresholdLow,
    BrightnessThreshold.normal => AlarmConstants.lightThresholdNormal,
    BrightnessThreshold.high => AlarmConstants.lightThresholdHigh,
  };

  int _getRequiredShakes(ShakeIntensity intensity) => switch (intensity) {
    ShakeIntensity.light => AlarmConstants.shakeCountLight,
    ShakeIntensity.medium => AlarmConstants.shakeCountMedium,
    ShakeIntensity.strong => AlarmConstants.shakeCountStrong,
  };

  void _onShake() {
    setState(() {
      _shakeCount++;
      _shakeRequirementMet = _shakeCount >= _requiredShakes;
    });
  }

  void _cleanup() {
    _shakeDetector?.stopListening();
    _lightDetector?.stopMonitoring();
    _lightSubscription?.cancel();
    WakelockPlus.disable();
  }

  Future<void> _dismissAlarm() async {
    if (!_canDismiss) return;

    _cleanup();
    _alarmService.cancelAlarm(widget.alarm.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  bool get _canDismiss => _shakeRequirementMet && _lightRequirementMet;

  bool get _hasShakeRequirement => _requiredShakes > 0;

  bool get _hasLightRequirement => _lightThreshold > 0;

  @override
  void dispose() {
    _cleanup();
    _lightDetector?.dispose();
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
                      if (_hasShakeRequirement)
                        _RequirementCard(
                          icon: Icons.vibration,
                          title: 'Shake Phone',
                          subtitle: '$_shakeCount / $_requiredShakes shakes',
                          isCompleted: _shakeRequirementMet,
                          progress: _shakeCount / _requiredShakes,
                        ),
                      if (_hasShakeRequirement && _hasLightRequirement)
                        const SizedBox(height: 16),
                      if (_hasLightRequirement)
                        _RequirementCard(
                          icon: Icons.light_mode,
                          title: 'Turn on Light',
                          subtitle:
                              '${_currentLightLevel.toStringAsFixed(0)} / $_lightThreshold lux',
                          isCompleted: _lightRequirementMet,
                          progress: (_currentLightLevel / _lightThreshold)
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
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
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
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green
              : Colors.white.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
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
