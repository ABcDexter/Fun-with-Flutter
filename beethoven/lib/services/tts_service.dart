import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_logger.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize TTS service
  Future<void> initialize() async {
    try {
      AppLogger.info('TTSService', 'initialize() started');
      // Set language to Indian English
      await _tts.setLanguage('en-IN');

      // Set voice parameters
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);

      // Voice is set, initialization complete
      _isInitialized = true;
      AppLogger.info('TTSService', 'initialize() completed');
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'initialize');
      rethrow;
    }
  }

  /// Speak text with Indian English accent
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      AppLogger.info('TTSService', 'speak() textLength=${text.length}');
      await _tts.speak(text);
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'speak');
      rethrow;
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      AppLogger.info('TTSService', 'stop()');
      await _tts.stop();
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'stop');
    }
  }

  /// Pause speech
  Future<void> pause() async {
    try {
      AppLogger.info('TTSService', 'pause()');
      await _tts.pause();
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'pause');
    }
  }

  /// Set speech rate (0.0 - 2.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      AppLogger.info('TTSService', 'setSpeechRate($rate)');
      await _tts.setSpeechRate(rate.clamp(0.0, 2.0));
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'setSpeechRate');
    }
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      AppLogger.info('TTSService', 'setPitch($pitch)');
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'setPitch');
    }
  }

  /// Dispose TTS resources
  Future<void> dispose() async {
    try {
      AppLogger.info('TTSService', 'dispose()');
      await _tts.stop();
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'dispose');
    }
  }

  /// Get available voices
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      AppLogger.info('TTSService', 'getAvailableVoices()');
      return await _tts.getVoices;
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'getAvailableVoices');
      return [];
    }
  }

  /// Set specific voice
  Future<void> setVoice(String voiceId) async {
    try {
      AppLogger.info('TTSService', 'setVoice($voiceId)');
      await _tts.setVoice({'name': voiceId, 'locale': 'en-IN'});
    } catch (e, st) {
      AppLogger.error('TTSService', e, st, 'setVoice');
    }
  }
}
