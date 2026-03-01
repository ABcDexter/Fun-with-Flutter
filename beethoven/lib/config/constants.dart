/// ML Model Configuration
class MLModelConstants {
  static const String modelPath = 'assets/models/isl_recognition_model.tflite';
  static const int inputWidth = 224;
  static const int inputHeight = 224;
  static const int numberOfClasses = 100;
  static const double confidenceThreshold = 0.7;
  static const int batchSize = 1;
}

/// Camera Configuration
class CameraConstants {
  static const int frameRate = 30;
  static const int processingInterval = 100; // ms
}

/// Text-to-Speech Configuration
class TTSConstants {
  static const String languageCode = 'en-IN';
  static const String locale = 'en-IN';
  static const double speechRate = 0.5;
  static const double pitch = 1.0;
}

/// ISL Vocabulary Size
class VocabularyConstants {
  static const int initialVocabularySize = 50;
  static const int extendedVocabularySize = 100;
}
