import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../constants/alarm_constant.dart';

class ShakeDetectorService {
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  final Stream<UserAccelerometerEvent> _accelerometerStream;
  double _shakeThreshold = AlarmConstants.shakeThresholdLight;
  DateTime? _lastShakeTime;
  static const _shakeCooldown = AlarmConstants.shakeCooldown;

  ShakeDetectorService({Stream<UserAccelerometerEvent>? accelerometerStream})
    : _accelerometerStream =
          accelerometerStream ?? userAccelerometerEventStream();

  void startListening(
    Function() onShake, {
    double threshold = AlarmConstants.shakeThresholdLight,
  }) {
    if (_subscription != null) return;

    _shakeThreshold = threshold;
    _lastShakeTime = null;

    _subscription = _accelerometerStream.listen((event) {
      final now = DateTime.now();

      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!) < _shakeCooldown) {
        return;
      }

      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        _lastShakeTime = now;
        try {
          onShake();
        } catch (_) {}
      }
    }, onError: (e) {});
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _lastShakeTime = null;
  }
}
