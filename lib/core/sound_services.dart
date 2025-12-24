import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class SoundPlayer {
  static final SoundPlayer _instance = SoundPlayer._internal();

  factory SoundPlayer() => _instance;

  final AudioPlayer _player = AudioPlayer();
  late String? _currentAssetPath = '';

  SoundPlayer._internal();

  /// Plays a sound from assets like 'sounds/success.mp3'
  Future<void> playSound(String assetPath) async {
    try {
      final fullPath = 'assets/$assetPath';
      // Avoid resetting if the same sound is already loaded

      await _player.stop();
      await _player.setAudioSource(AudioSource.asset(fullPath));
      _currentAssetPath = fullPath;

      await _player.play();
    } catch (e) {
      debugPrint(
        'Error playing sound: $e',
      ); // Replace with proper logging in production
    }
  }

  /// Stops the currently playing sound
  Future<void> stop() async {
    await _player.stop();
    _currentAssetPath = null; // Clear current sound
  }

  /// Disposes the audio player
  void dispose() {
    _player.dispose();
  }
}
