import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';
import '../services/tts_service.dart';
import '../services/ml_service.dart';
import '../utils/app_logger.dart';

// Camera Service Provider
final cameraServiceProvider = Provider<CameraService>((ref) {
  AppLogger.info('Providers', 'cameraServiceProvider created');
  return CameraService();
});

// TTS Service Provider
final ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  AppLogger.info('Providers', 'ttsServiceProvider created');
  return TextToSpeechService();
});

// ML Service Provider
final mlServiceProvider = Provider<ISLMLService>((ref) {
  AppLogger.info('Providers', 'mlServiceProvider created');
  return ISLMLService();
});

// Camera Initialization Provider
final cameraInitializationProvider = FutureProvider<void>((ref) async {
  AppLogger.info('Providers', 'cameraInitializationProvider started');
  final cameraService = ref.watch(cameraServiceProvider);
  await cameraService.initialize();
  AppLogger.info('Providers', 'cameraInitializationProvider completed');
});

// TTS Initialization Provider
final ttsInitializationProvider = FutureProvider<void>((ref) async {
  AppLogger.info('Providers', 'ttsInitializationProvider started');
  final ttsService = ref.watch(ttsServiceProvider);
  await ttsService.initialize();
  AppLogger.info('Providers', 'ttsInitializationProvider completed');
});

// ML Model Loading Provider
final mlModelLoadingProvider = FutureProvider<void>((ref) async {
  AppLogger.info('Providers', 'mlModelLoadingProvider started');
  final mlService = ref.watch(mlServiceProvider);
  await mlService.loadModel('assets/models/isl_recognition_model.tflite');
  AppLogger.info('Providers', 'mlModelLoadingProvider completed');
});

// Recognition Result Provider
final recognitionResultProvider = StateProvider<Map<String, dynamic>>((ref) {
  AppLogger.info('Providers', 'recognitionResultProvider initialized');
  return {
    'text': '',
    'confidence': 0.0,
  };
});

// Translation History Provider
final translationHistoryProvider = StateProvider<List<String>>((ref) {
  AppLogger.info('Providers', 'translationHistoryProvider initialized');
  return [];
});
