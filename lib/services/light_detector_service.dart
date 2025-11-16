import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/alarm_constant.dart';

class LightDetectorService {
  static const MethodChannel _methodChannel = MethodChannel(
    AlarmConstants.sensorChannel,
  );
  static const EventChannel _eventChannel = EventChannel(
    AlarmConstants.lightEventChannel,
  );

  StreamSubscription? _subscription;
  final StreamController<double> _lightController =
      StreamController<double>.broadcast();

  void startMonitoring() async {
    try {
      await _methodChannel.invokeMethod(AlarmConstants.methodStartLightSensor);
      _subscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is double) {
            _lightController.add(event);
          }
        },
        onError: (error) {
          print('Light sensor error: $error');
        },
      );
    } catch (e) {
      print('Failed to start light sensor: $e');
    }
  }

  void stopMonitoring() async {
    try {
      await _subscription?.cancel();
      await _methodChannel.invokeMethod(AlarmConstants.methodStopLightSensor);
    } catch (e) {
      print('Failed to stop light sensor: $e');
    }
  }

  Stream<double> getLightStream() => _lightController.stream;

  void dispose() {
    _subscription?.cancel();
    _lightController.close();
  }
}
