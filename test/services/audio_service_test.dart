import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:getup/services/audio_service.dart';
import 'package:getup/services/vibration_api.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}
class _MockVibrationApi extends Mock implements VibrationApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(LoopMode.one);
  });

  group('AudioService', () {
    late _MockAudioPlayer player;
    late _MockVibrationApi vibration;
    late AudioService service;

    setUp(() {
      player = _MockAudioPlayer();
      vibration = _MockVibrationApi();
      service = AudioService(player: player, vibration: vibration);
    });

    test('playAlarm plays asset, loops, and vibrates when available', () async {
      when(() => player.setAsset('assets/marimba.mp3'))
          .thenAnswer((_) async => Duration.zero);
      when(() => player.setLoopMode(LoopMode.one))
          .thenAnswer((_) async {});
      when(() => player.play()).thenAnswer((_) async {});
      when(() => vibration.hasVibrator()).thenAnswer((_) async => true);
      when(() => vibration.vibrate(pattern: any(named: 'pattern'), repeat: any(named: 'repeat')))
          .thenAnswer((_) async {});

      await service.playAlarm();

      verify(() => player.setAsset('assets/marimba.mp3')).called(1);
      verify(() => player.setLoopMode(LoopMode.one)).called(1);
      verify(() => player.play()).called(1);
      verify(() => vibration.hasVibrator()).called(1);
      verify(() => vibration.vibrate(pattern: [500, 1000], repeat: 0))
          .called(1);
      verifyNoMoreInteractions(player);
      verifyNoMoreInteractions(vibration);
    });

    test('playAlarm falls back to vibration when audio throws', () async {
      when(() => player.setAsset('assets/marimba.mp3'))
          .thenThrow(Exception('asset error'));
      when(() => vibration.vibrate(pattern: any(named: 'pattern'), repeat: any(named: 'repeat')))
          .thenAnswer((_) async {});

      await service.playAlarm();

      verify(() => player.setAsset('assets/marimba.mp3')).called(1);
      // No play/loop expected due to error
      verifyNever(() => player.setLoopMode(any()));
      verifyNever(() => player.play());
      verify(() => vibration.vibrate(pattern: [500, 1000], repeat: 0))
          .called(1);
      verifyNoMoreInteractions(player);
      verifyNoMoreInteractions(vibration);
    });

    test('stopAlarm stops player and cancels vibration', () async {
      when(() => player.stop()).thenAnswer((_) async {});
      when(() => vibration.cancel()).thenAnswer((_) async {});

      await service.stopAlarm();

      verify(() => player.stop()).called(1);
      verify(() => vibration.cancel()).called(1);
      verifyNoMoreInteractions(player);
      verifyNoMoreInteractions(vibration);
    });

    test('dispose disposes the player', () {
      when(() => player.dispose()).thenAnswer((_) async {});

      service.dispose();

      verify(() => player.dispose()).called(1);
      verifyNoMoreInteractions(player);
      verifyZeroInteractions(vibration);
    });
  });
}


