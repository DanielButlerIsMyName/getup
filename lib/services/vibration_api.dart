import 'package:vibration/vibration.dart';

abstract class VibrationApi {
  Future<bool> hasVibrator();
  Future<void> vibrate({required List<int> pattern, int repeat = 0});
  Future<void> cancel();
}

class PackageVibrationApi implements VibrationApi {
  @override
  Future<bool> hasVibrator() async {
    return Vibration.hasVibrator();
  }

  @override
  Future<void> vibrate({required List<int> pattern, int repeat = 0}) {
    return Vibration.vibrate(pattern: pattern, repeat: repeat);
  }

  @override
  Future<void> cancel() {
    return Vibration.cancel();
  }
}


