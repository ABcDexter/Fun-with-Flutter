import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/camera_service.dart';
import '../services/tts_service.dart';
import '../services/ml_service.dart';

// Camera Service Provider
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

// TTS Service Provider
final ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechService();
});

// ML Service Provider
final mlServiceProvider = Provider<ISLMLService>((ref) {
  return ISLMLService();
});

// Camera Initialization Provider
final cameraInitializationProvider = FutureProvider<void>((ref) async {
  final cameraService = ref.watch(cameraServiceProvider);
  await cameraService.initialize();
});

// TTS Initialization Provider
final ttsInitializationProvider = FutureProvider<void>((ref) async {
  final ttsService = ref.watch(ttsServiceProvider);
  await ttsService.initialize();
});

// ML Model Loading Provider
final mlModelLoadingProvider = FutureProvider<void>((ref) async {
  final mlService = ref.watch(mlServiceProvider);
  await mlService.loadModel('assets/models/isl_recognition_model.tflite');
});

// Recognition Result Provider
final recognitionResultProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'text': '',
    'confidence': 0.0,
  };
});

// Translation History Provider
final translationHistoryProvider = StateProvider<List<String>>((ref) {
  return [];
});
