import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import '../config/constants.dart';
import '../utils/app_logger.dart';

class ISLMLService {
  late tflite.Interpreter _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Load TensorFlow Lite model
  Future<void> loadModel(String modelPath) async {
    try {
      AppLogger.info('MLServiceMobile', 'loadModel() path=$modelPath');
      // Load the model from assets
      final buffer = await rootBundle.load(modelPath);
      _interpreter = tflite.Interpreter.fromBuffer(
        buffer.buffer.asUint8List(),
      );
      _isInitialized = true;
      AppLogger.info('MLServiceMobile', 'Model loaded successfully');
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'loadModel');
      rethrow;
    }
  }

  /// Preprocess image frame
  List<List<List<List<num>>>> preprocessFrame(List<int> imageData, int width, int height) {
    // Normalize pixel values (0-255 -> 0-1)
    List<List<List<List<num>>>> input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(
          width,
          (x) {
            final pixelIndex = (y * width + x) * 3;
            final r = imageData[pixelIndex] / 255.0;
            final g = imageData[pixelIndex + 1] / 255.0;
            final b = imageData[pixelIndex + 2] / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );
    return input;
  }

  /// Run inference on preprocessed frame
  Future<List<double>> runInference(List<List<List<List<num>>>> input) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized');
    }

    try {
      final output = List<double>.filled(100, 0); // 100 classes for ISL signs
      _interpreter.run(input, output);
      return output;
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'runInference');
      rethrow;
    }
  }

  /// Run inference on preprocessed sequence for 3D CNN
  Future<List<double>> runInference3dcnn(
    List<List<List<List<List<num>>>>> input,
  ) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized');
    }

    try {
      final output = List.generate(
        1,
        (_) => List<double>.filled(MLModelConstants.numberOfClasses, 0),
      );
      _interpreter.run(input, output);
      return output.first;
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'runInference3dcnn');
      rethrow;
    }
  }

  /// Process video frames and return predictions
  Future<Map<String, dynamic>> processFrame(
    List<int> frameData,
    int width,
    int height,
  ) async {
    try {
      // Preprocess frame
      final preprocessed = preprocessFrame(frameData, width, height);

      // Run inference
      final predictions = await runInference(preprocessed);

      // Get top prediction
      int maxIndex = 0;
      double maxValue = predictions[0];

      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxValue) {
          maxValue = predictions[i];
          maxIndex = i;
        }
      }

      return {
        'classIndex': maxIndex,
        'confidence': maxValue,
        'allPredictions': predictions,
      };
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'processFrame');
      rethrow;
    }
  }

  /// Get input details
  Map<String, dynamic> getInputDetails() {
    try {
      final inputTensors = _interpreter.getInputTensors();
      return {
        'shape': inputTensors[0].shape,
        'type': inputTensors[0].type,
      };
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'getInputDetails');
      return {};
    }
  }

  /// Get output details
  Map<String, dynamic> getOutputDetails() {
    try {
      final outputTensors = _interpreter.getOutputTensors();
      return {
        'shape': outputTensors[0].shape,
        'type': outputTensors[0].type,
      };
    } catch (e, st) {
      AppLogger.error('MLServiceMobile', e, st, 'getOutputDetails');
      return {};
    }
  }

  /// Dispose model
  void dispose() {
    if (_isInitialized) {
      AppLogger.info('MLServiceMobile', 'dispose()');
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
