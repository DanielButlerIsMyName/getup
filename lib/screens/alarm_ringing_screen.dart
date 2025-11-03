import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/alarm_model.dart';
import '../services/audio_service.dart';
import '../services/shake_detector_service.dart';
import '../services/light_detector_service.dart';

class AlarmRingingScreen extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final AudioService _audioService = AudioService();
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  final LightDetectorService _lightDetector = LightDetectorService();

  bool _shakeDismissed = false;
  bool _lightDismissed = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _audioService.playAlarm();
    _setupDismissConditions();
  }

  void _setupDismissConditions() {
    if (widget.alarm.requireShake) {
      _shakeDetector.startListening(() {
        setState(() {
          _shakeDismissed = true;
        });
        _checkDismiss();
      });
    }

    if (widget.alarm.requireLight) {
      _lightDetector.startMonitoring();
      _lightDetector.getLightStream().listen((lux) {
        if (lux >= LightDetectorService.lightThreshold) {
          setState(() {
            _lightDismissed = true;
          });
          _checkDismiss();
        }
      });
    }
  }

  void _checkDismiss() {
    final shakeOk = !widget.alarm.requireShake || _shakeDismissed;
    final lightOk = !widget.alarm.requireLight || _lightDismissed;

    if (shakeOk && lightOk) {
      _dismissAlarm();
    }
  }

  void _dismissAlarm() {
    _audioService.stopAlarm();
    _shakeDetector.stopListening();
    _lightDetector.stopMonitoring();
    WakelockPlus.disable();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _audioService.stopAlarm();
    _shakeDetector.stopListening();
    _lightDetector.stopMonitoring();
    _lightDetector.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                '${widget.alarm.scheduledTime.hour.toString().padLeft(2, '0')}:${widget.alarm.scheduledTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              if (widget.alarm.requireShake)
                _buildCondition(
                  'Shake Phone',
                  _shakeDismissed,
                  Icons.phone_android,
                ),
              if (widget.alarm.requireLight)
                _buildCondition(
                  'Expose to Light',
                  _lightDismissed,
                  Icons.lightbulb,
                ),
              if (!widget.alarm.requireShake && !widget.alarm.requireLight)
                ElevatedButton(
                  onPressed: _dismissAlarm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCondition(String label, bool completed, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? Colors.green : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (completed) ...[
            const SizedBox(width: 16),
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 32,
            ),
          ],
        ],
      ),
    );
  }
}