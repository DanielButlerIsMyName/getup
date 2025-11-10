import 'dart:async';
import 'package:flutter/services.dart';

class LightDetectorService {
  static const int lightThreshold = 100; // lux threshold for dismissing alarm
  static const platform = MethodChannel('com.getup.alarm/sensors');
  static const eventChannel = EventChannel('com.getup.alarm/light_sensor');

  final StreamController<double> _controller = StreamController<double>.broadcast();
  StreamSubscription<double>? _subscription;
  bool _isLightDetected = false;

  // Real light detection using Android ambient light sensor
  Future<bool> checkLightLevel() async {
    return _isLightDetected;
  }

  Stream<double> getLightStream() {
    return _controller.stream;
  }

  void startMonitoring() {
    // Start listening to the platform channel
    platform.invokeMethod('startLightSensor').catchError((error) {
      print("Failed to start light sensor: $error");
    });

    _subscription = eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => (event as num).toDouble())
        .listen(
          (double lux) {
            _isLightDetected = lux >= lightThreshold;
            _controller.add(lux);
          },
          onError: (error) {
            print('Light sensor stream error: $error');
          },
        );
  }

  void stopMonitoring() {
    _subscription?.cancel();
    platform.invokeMethod('stopLightSensor').catchError((error) {
      print("Failed to stop light sensor: $error");
    });
    _isLightDetected = false;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
