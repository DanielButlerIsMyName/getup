import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';

class ShakeDetectorService {
  static const double shakeThreshold = 15.0;
  StreamSubscription? _subscription;

  void startListening(Function() onShake) {
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
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
