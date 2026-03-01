import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;

class ISLMLService {
  late tflite.Interpreter _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Load TensorFlow Lite model
  Future<void> loadModel(String modelPath) async {
    try {
      // Load the model from assets
      final buffer = await rootBundle.load(modelPath);
      _interpreter = await tflite.Interpreter.fromBuffer(
        buffer.buffer.asUint8List()
      );
      _isInitialized = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
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
    } catch (e) {
      print('Error running inference: $e');
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
    } catch (e) {
      print('Error processing frame: $e');
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
    } catch (e) {
      print('Error getting input details: $e');
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
    } catch (e) {
      print('Error getting output details: $e');
      return {};
    }
  }

  /// Dispose model
  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
