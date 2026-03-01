import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize TTS service
  Future<void> initialize() async {
    try {
      // Set language to Indian English
      await _tts.setLanguage('en-IN');

      // Set voice parameters
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);

      // Voice is set, initialization complete
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
      rethrow;
    }
  }

  /// Speak text with Indian English accent
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
      rethrow;
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  /// Pause speech
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (e) {
      print('Error pausing speech: $e');
    }
  }

  /// Set speech rate (0.0 - 2.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.0, 2.0));
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      print('Error setting pitch: $e');
    }
  }

  /// Dispose TTS resources
  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error disposing TTS: $e');
    }
  }

  /// Get available voices
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await _tts.getVoices;
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }

  /// Set specific voice
  Future<void> setVoice(String voiceId) async {
    try {
      await _tts.setVoice({'name': voiceId, 'locale': 'en-IN'});
    } catch (e) {
      print('Error setting voice: $e');
    }
  }
}
