class SignRecognitionResult {
  final String sign;
  final String englishText;
  final double confidence;
  final int frameCount;
  final DateTime timestamp;

  SignRecognitionResult({
    required this.sign,
    required this.englishText,
    required this.confidence,
    required this.frameCount,
    required this.timestamp,
  });
}

class MLModelConfig {
  final String modelPath;
  final int inputWidth;
  final int inputHeight;
  final int numberOfClasses;
  final double confidenceThreshold;
  final int batchSize;

  MLModelConfig({
    required this.modelPath,
    required this.inputWidth,
    required this.inputHeight,
    required this.numberOfClasses,
    required this.confidenceThreshold,
    required this.batchSize,
  });
}

class ISLVocabularyItem {
  final int id;
  final String sign;
  final String englishTranslation;
  final List<String> alternativeNames;
  final String category;
  final String description;

  ISLVocabularyItem({
    required this.id,
    required this.sign,
    required this.englishTranslation,
    required this.alternativeNames,
    required this.category,
    required this.description,
  });
}
