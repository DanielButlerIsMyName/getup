import 'package:flutter/services.dart';
import 'dart:async';

class LightSensorService {
  static const platform = MethodChannel('com.getup.alarm/sensors');
  static const eventChannel = EventChannel('com.getup.alarm/light_sensor');

  Stream<double>? _lightStream;

  Stream<double> getLightSensorStream() {
    _lightStream ??= eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => (event as num).toDouble());
    return _lightStream!;
  }

  Future<void> startListening() async {
    try {
      await platform.invokeMethod('startLightSensor');
    } on PlatformException catch (e) {
      print("Failed to start light sensor: ${e.message}");
    }
  }

  Future<void> stopListening() async {
    try {
      await platform.invokeMethod('stopLightSensor');
    } on PlatformException catch (e) {
      print("Failed to stop light sensor: ${e.message}");
    }
  }
}

