import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';

class ShakeDetectorService {
  StreamSubscription? _subscription;
  final Stream<AccelerometerEvent> _accelerometerStream;
  double _shakeThreshold = 15.0;
  DateTime? _lastShakeTime;
  static const _shakeCooldown = Duration(milliseconds: 500);

  ShakeDetectorService({Stream<AccelerometerEvent>? accelerometerStream})
    : _accelerometerStream = accelerometerStream ?? accelerometerEvents;

  void startListening(Function() onShake, {double threshold = 15.0}) {
    _shakeThreshold = threshold;
    _lastShakeTime = null;

    _subscription = _accelerometerStream.listen((AccelerometerEvent event) {
      final now = DateTime.now();

      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!) < _shakeCooldown) {
        return;
      }

      double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        _lastShakeTime = now;
        onShake();
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _lastShakeTime = null;
  }
}
