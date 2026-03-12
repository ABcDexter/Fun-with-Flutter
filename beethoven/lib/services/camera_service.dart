import 'package:camera/camera.dart';
import '../utils/app_logger.dart';

class CameraService {
  late CameraController _controller;
  List<CameraDescription> cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController get controller => _controller;

  /// Initialize camera service and get available cameras
  Future<void> initialize() async {
    try {
      AppLogger.info('CameraService', 'initialize() started');
      cameras = await availableCameras();
      AppLogger.info('CameraService', 'availableCameras() -> ${cameras.length}');
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use front camera for sign language recognition
      final CameraDescription camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller.initialize();
      _isInitialized = true;
      AppLogger.info('CameraService', 'CameraController initialized');
    } catch (e, st) {
      AppLogger.error('CameraService', e, st, 'initialize');
      rethrow;
    }
  }

  /// Start camera preview
  Future<void> startPreview() async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }
    try {
      AppLogger.info('CameraService', 'startPreview() started');
      await _controller.startImageStream((image) {
        // Process frames for ML inference
      });
      AppLogger.info('CameraService', 'startPreview() stream started');
    } catch (e, st) {
      AppLogger.error('CameraService', e, st, 'startPreview');
      rethrow;
    }
  }

  /// Stop camera preview
  Future<void> stopPreview() async {
    if (_isInitialized) {
      try {
        AppLogger.info('CameraService', 'stopPreview()');
        await _controller.stopImageStream();
      } catch (e, st) {
        AppLogger.error('CameraService', e, st, 'stopPreview');
      }
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        AppLogger.info('CameraService', 'dispose()');
        await _controller.dispose();
        _isInitialized = false;
      } catch (e, st) {
        AppLogger.error('CameraService', e, st, 'dispose');
      }
    }
  }

  /// Capture a single frame
  Future<XFile?> captureFrame() async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }
    try {
      AppLogger.info('CameraService', 'captureFrame()');
      return await _controller.takePicture();
    } catch (e, st) {
      AppLogger.error('CameraService', e, st, 'captureFrame');
      return null;
    }
  }
}
