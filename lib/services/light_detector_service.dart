import 'dart:async';

class LightDetectorService {
  static const int lightThreshold = 100;
  final StreamController<int> _controller = StreamController<int>.broadcast();
  Timer? _timer;
  bool _isLightDetected = false;

  // Simulated light detection using a timer
  // In a real implementation, you would use camera or another sensor
  Future<bool> checkLightLevel() async {
    // For now, we'll use a timer-based approach where the user needs to
    // keep the phone exposed to light for a few seconds
    return _isLightDetected;
  }

  Stream<int> getLightStream() {
    return _controller.stream;
  }

  void startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Simulate light detection - in production, you'd use camera brightness
      // or another method to detect ambient light
      _isLightDetected = true;
      _controller.add(150); // Simulated lux value above threshold
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _isLightDetected = false;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
