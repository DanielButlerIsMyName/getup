import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAlarm() async {
    try {
      await _player.setAsset('assets/alarm.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.play();

      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(pattern: [500, 1000], repeat: 0);
      }
    } catch (e) {
      // Fallback: just vibrate if audio fails
      Vibration.vibrate(pattern: [500, 1000], repeat: 0);
    }
  }

  Future<void> stopAlarm() async {
    await _player.stop();
    Vibration.cancel();
  }

  void dispose() {
    _player.dispose();
  }
}