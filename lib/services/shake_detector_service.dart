import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';

class ShakeDetectorService {
  static const double shakeThreshold = 15.0;
  StreamSubscription? _subscription;
  final Stream<AccelerometerEvent> _accelerometerStream;

  ShakeDetectorService({Stream<AccelerometerEvent>? accelerometerStream})
    : _accelerometerStream = accelerometerStream ?? accelerometerEvents;

  void startListening(Function() onShake) {
    _subscription = _accelerometerStream.listen((AccelerometerEvent event) {
      double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > shakeThreshold) {
        onShake();
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
