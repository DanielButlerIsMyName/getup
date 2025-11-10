import 'package:just_audio/just_audio.dart';
import 'vibration_api.dart';

class AudioService {
  final AudioPlayer _player;
  final VibrationApi _vibration;

  AudioService({AudioPlayer? player, VibrationApi? vibration})
    : _player = player ?? AudioPlayer(),
      _vibration = vibration ?? PackageVibrationApi();

  Future<void> playAlarm() async {
    try {
      await _player.setAsset('assets/marimba.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.play();

      final hasVibrator = await _vibration.hasVibrator();
      if (hasVibrator) {
        await _vibration.vibrate(pattern: [500, 1000], repeat: 0);
      }
    } catch (e) {
      // Fallback: just vibrate if audio fails
      await _vibration.vibrate(pattern: [500, 1000], repeat: 0);
    }
  }

  Future<void> stopAlarm() async {
    await _player.stop();
    await _vibration.cancel();
  }

  void dispose() {
    _player.dispose();
  }
}
