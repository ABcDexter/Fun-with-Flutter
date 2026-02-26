# Beethoven - Indian Sign Language to English Voice Converter

An advanced Flutter application that uses machine learning to convert live Indian Sign Language (ISL) video from the camera into English voice. This is a research-grade ML-powered application built by an ML engineer with PhD credentials.

## 🎯 Project Vision

To create an accessible, real-time translation system that bridges the communication gap between sign language users and English speakers through intelligent video analysis and natural voice synthesis.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                         │
├─────────────────────────────────────────────────────────────┤
│  Home Screen → Camera Screen → Recognition Display          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Video Processing Pipeline                      │
├─────────────────────────────────────────────────────────────┤
│  Camera Input → Frame Preprocessing → ML Inference          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│           TensorFlow Lite Model Execution                   │
├─────────────────────────────────────────────────────────────┤
│  MediaPipe Pose Detection → LSTM/3D-CNN → Sign Classification
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         Text-to-Speech with Indian Accent                   │
├─────────────────────────────────────────────────────────────┤
│  Google Cloud TTS API / Flutter TTS → Audio Output          │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Flutter**: >= 3.0.0
- **Dart**: >= 3.0.0
- **Python**: >= 3.8 (for model training)
- **TensorFlow**: >= 2.10
- **macOS/iOS/Android** device for testing

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/ABcDexter/Fun-with-Flutter.git
cd Fun-with-Flutter/beethoven
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Set up Python environment (for model training)**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r scripts/requirements.txt
```

4. **Run the app**
```bash
flutter run
```

## 📋 Project Structure

```
beethoven/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── config/
│   │   ├── constants.dart             # ML & app constants
│   │   └── providers.dart             # Riverpod providers
│   ├── features/
│   │   ├── camera/                    # Camera functionality
│   │   │   └── camera_screen.dart
│   │   ├── ml/                        # ML inference
│   │   │   └── isl_interpreter.dart
│   │   ├── recognition/               # Sign recognition
│   │   │   └── sign_recognizer.dart
│   │   ├── tts/                       # Text-to-speech
│   │   │   └── speech_service.dart
│   │   └── ui/                        # UI screens
│   │       └── home_screen.dart
│   ├── models/                        # Data models
│   │   └── recognition_models.dart
│   ├── services/                      # Core services
│   │   ├── camera_service.dart
│   │   ├── ml_service.dart
│   │   └── tts_service.dart
│   └── utils/                         # Utilities
│       └── extensions.dart
├── scripts/
│   ├── train_model.py                 # Model training
│   ├── vocabulary.py                  # ISL vocabulary
│   ├── recognition_engine.py          # Recognition logic
│   └── requirements.txt
├── assets/
│   ├── models/
│   │   └── isl_recognition_model.tflite
│   ├── data/
│   └── isl_vocabulary/
├── pubspec.yaml                       # Flutter dependencies
└── PROJECT_PLAN.md                    # Detailed project plan
```

## 🤖 Machine Learning Pipeline

### Dataset
- **Source**: [ISLAR - Hugging Face](https://huggingface.co/datasets/akshaybahadur21/ISLAR)
- **Size**: 10,000+ ISL gesture videos
- **Classes**: 100 common ISL signs

### Model Training

#### Step 1: Download Dataset
```bash
cd scripts
python3 download_dataset.py
```
Downloads to `assets/data/islar` by default. Use `--output_dir` to change it.

#### Step 2: Train Model
```bash
python3 train_model.py \
  --model_type lstm_mediapipe \
  --vocabulary_size 100 \
  --sequence_length 30 \
  --epochs 50
```

#### Step 3: Convert to TensorFlow Lite
The training script automatically converts to `.tflite` format optimized for mobile devices.

### Model Architecture Options

**Option 1: MediaPipe Pose + LSTM** (Recommended for Mobile)
- **Input**: Pose landmarks from 30 frames
- **Processing**: LSTM layers with attention
- **Output**: Sign classification (100 classes)
- **Advantages**: Lightweight, fast inference, robust to scale changes
- **Size**: ~10MB

**Option 2: 3D Convolutional Neural Network**
- **Input**: Stacked video frames (30 frames × 224×224)
- **Processing**: 3D convolutions + pooling
- **Output**: Sign classification
- **Advantages**: Better spatial-temporal understanding
- **Size**: ~50MB

### Model Performance Metrics

| Metric | Target | Expected |
|--------|--------|----------|
| Accuracy | 85%+ | 87-92% |
| Top-5 Accuracy | 95%+ | 96-98% |
| Inference Time | <500ms | 200-400ms |
| Model Size | <100MB | 10-50MB |
| RAM Usage | <300MB | 150-250MB |

## 🎬 Features

### Current Implementation
- ✅ Real-time camera feed capture
- ✅ Frame preprocessing pipeline
- ✅ TensorFlow Lite model inference
- ✅ MediaPipe pose detection integration
- ✅ Text-to-Speech with Indian English accent
- ✅ Confidence scoring and visualization
- ✅ Translation history tracking

### Planned Features
- 🔄 Multi-language support (Hindi, Punjabi, etc.)
- 🔄 Sentence-level understanding
- 🔄 Offline mode with cached TTS voices
- 🔄 User profile and learning statistics
- 🔄 Community-driven sign corrections
- 🔄 Video recording with subtitles

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Ready | iOS 12+ required |
| Android | ✅ Ready | Android 8+ required |
| Web | 🔄 In Progress | Camera limited on browsers |
| macOS | ✅ Ready | Development/Testing |
| Windows | 🔄 Planned | Coming soon |
| Linux | 🔄 Planned | Coming soon |

## 🔐 API Integration

### Google Cloud Text-to-Speech
For natural-sounding Indian English voice synthesis:

```bash
# Set up credentials
export GOOGLE_APPLICATION_CREDENTIALS="path/to/credentials.json"
```

### Alternative: Microsoft Azure
For enterprise-grade speech synthesis with multiple Indian voices.

## 📊 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 🏗️ Build & Deployment

### Android Release Build
```bash
flutter build apk --release
# or for Android App Bundle
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web --release
```

## 📚 Documentation

- **[PROJECT_PLAN.md](PROJECT_PLAN.md)** - Comprehensive technical specification
- **[Model Training Guide](scripts/train_model.py)** - Detailed training instructions
- **[API Documentation](lib/)** - Code API documentation

## 🔬 Research & References

### Key Papers
- Action Recognition in Videos (3D CNN)
- Sign Language Recognition with Pose Estimation
- Transformer-based Temporal Modeling for Action Recognition

### Datasets
- ISLAR (Indian Sign Language Action Recognition)
- ASL Dataset (for comparison)
- AUTSL (Ankara University Turkish Sign Language)

## 💡 Technical Insights

### Why MediaPipe + LSTM for Mobile?
1. **Efficiency**: Pose detection is lightweight and fast
2. **Robustness**: Works across different body sizes and positions
3. **No redundancy**: Focuses on meaningful gesture information
4. **Scalability**: Easy to add new signs without retraining entire model

### Inference Pipeline Optimization
```
Frame Capture (30 FPS)
    ↓ (Skip 2/3 frames)
Pose Detection (10 FPS)
    ↓ (Every 30 frames = 3 seconds)
Model Inference
    ↓
Confidence Check
    ↓ (If >70%)
Text-to-Speech Generation
```

## 🎓 Academic Context

**Author Profile**: Deep interest in Machine Learning  
**Expertise**: 
- Deep Learning & Computer Vision
- Real-time Inference Systems
- Accessibility Technology

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 🐛 Known Issues & Limitations

1. **Lighting Dependency**: Performance varies with lighting conditions
2. **Latency**: ~1-2 second delay between sign and speech output
3. **Vocabulary**: Limited to 100 most common ISL signs (expandable)
4. **Context**: No sentence-level understanding (sequential signs only)

## 🚦 Roadmap

### Phase 1: MVP (Current)
- Basic sign recognition
- Real-time video processing
- TTS integration

### Phase 2: Enhancement
- Improved accuracy (>90%)
- Multiple language support
- Offline mode

### Phase 3: Advanced
- Sentence understanding
- AI-powered suggestions
- Community platform

## 📞 Support

For issues, questions, or suggestions:
- 📧 Email: anubhav.balodhi@gmail.com
- 🐙 GitHub Issues: [Create an issue](https://github.com/ABcDexter/Fun-with-Flutter/issues)
- 💬 Discussions: [Start a discussion](https://github.com/ABcDexter/Fun-with-Flutter/discussions)

---

**Status**: Under Active Development  
**Last Updated**: February 8, 2026  
**Version**: 0.1.0-alpha
