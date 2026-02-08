import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  late CameraController _controller;
  List<CameraDescription> cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController get controller => _controller;

  /// Initialize camera service and get available cameras
  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
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
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  /// Start camera preview
  Future<void> startPreview() async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }
    try {
      await _controller.startImageStream((image) {
        // Process frames for ML inference
      });
    } catch (e) {
      debugPrint('Error starting preview: $e');
      rethrow;
    }
  }

  /// Stop camera preview
  Future<void> stopPreview() async {
    if (_isInitialized) {
      try {
        await _controller.stopImageStream();
      } catch (e) {
        debugPrint('Error stopping preview: $e');
      }
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _controller.dispose();
        _isInitialized = false;
      } catch (e) {
        debugPrint('Error disposing camera: $e');
      }
    }
  }

  /// Capture a single frame
  Future<XFile?> captureFrame() async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }
    try {
      return await _controller.takePicture();
    } catch (e) {
      debugPrint('Error capturing frame: $e');
      return null;
    }
  }
}
