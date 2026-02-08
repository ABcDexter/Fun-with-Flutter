# Beethoven - Complete Setup & Development Guide

## 📋 Prerequisites

### System Requirements
- **macOS**: 10.15+
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 20GB free (for datasets, models, and builds)

### Required Software
- Flutter SDK 3.0.0+
- Dart 3.0.0+
- Python 3.8+
- Xcode 13+ (for iOS development)
- Android Studio (for Android development)

## 🔧 Step-by-Step Setup

### 1. Install Flutter

```bash
# Using Homebrew (macOS)
brew install flutter

# Or download from flutter.dev
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter --version
flutter doctor
```

### 2. Clone the Repository

```bash
git clone https://github.com/ABcDexter/Fun-with-Flutter.git
cd Fun-with-Flutter/beethoven
```

### 3. Install Flutter Dependencies

```bash
# Get all pub dependencies
flutter pub get

# Analyze for any issues
flutter analyze

# Format code
dart format lib/ test/
```

### 4. Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate (macOS/Linux)
source venv/bin/activate

# Or on Windows
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r scripts/requirements.txt
```

### 5. Download ML Datasets

```bash
cd scripts

# Create data directory
mkdir -p ../assets/models
mkdir -p ../assets/data

# Download ISLAR dataset (requires huggingface-hub)
python3 download_dataset.py
```

### 6. Train ML Model

```bash
# Train model (this takes several hours)
python3 train_model.py \
  --model_type lstm_mediapipe \
  --vocabulary_size 100 \
  --batch_size 32 \
  --epochs 50

# Model will be saved as: isl_recognition_model.tflite
# Move to assets/models/
mv isl_recognition_model.tflite ../assets/models/
```

### 7. Configure API Keys

#### Google Cloud Text-to-Speech (Optional)

```bash
# Create Google Cloud project
# Enable Text-to-Speech API
# Create service account and download credentials.json

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="path/to/credentials.json"

# Or add to .env file
echo "GOOGLE_CLOUD_CREDENTIALS=path/to/credentials.json" > .env
```

### 8. Run the App

```bash
# List available devices
flutter devices

# Run on simulator/emulator
flutter run

# Run with specific device
flutter run -d <device-id>

# Run with verbose output
flutter run -v

# Run in release mode (optimized)
flutter run --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart -v
```

### Integration Tests
```bash
flutter test integration_test/ -v
```

### Test Coverage
```bash
flutter test --coverage
```

## 📱 Platform-Specific Setup

### iOS Development

```bash
# Install pods
cd ios
pod install
cd ..

# Run on iOS simulator
flutter run -d iPhone

# Build for iOS
flutter build ios --release

# Generate IPA
flutter build ipa
```

### Android Development

```bash
# Check Android setup
flutter doctor -v

# Run on Android emulator
flutter run -d emulator-5554

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### Web Development

```bash
# Enable web support
flutter config --enable-web

# Run on web
flutter run -d chrome

# Build web release
flutter build web --release
```

## 🔍 Troubleshooting

### Camera Permission Issues

**iOS**
```
Add to ios/Runner/Info.plist:
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to recognize signs</string>
<key>NSMicrophoneUsageDescription</key>
<string>For audio output</string>
```

**Android**
```
Add to android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### TensorFlow Lite Loading Issues

```bash
# Clean build
flutter clean

# Clear pub cache
flutter pub cache clean

# Rebuild
flutter pub get
flutter run
```

### Model File Not Found

```bash
# Ensure model exists in assets
ls assets/models/isl_recognition_model.tflite

# Check pubspec.yaml includes assets
# Should have:
# assets:
#   - assets/models/
```

### MediaPipe Installation Issues

```bash
# On macOS, you might need to install via Homebrew
brew install opencv

# Update TFLite Flutter
flutter pub upgrade tflite_flutter
```

## 🚀 Development Workflow

### 1. Create a Feature Branch
```bash
git checkout -b feature/new-feature
```

### 2. Make Changes
```bash
# Edit files, test locally
flutter run
```

### 3. Format & Analyze Code
```bash
dart format lib/
flutter analyze
flutter test
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: Add new feature"
git push origin feature/new-feature
```

### 5. Create Pull Request
- Go to GitHub
- Create PR against `main` branch
- Request review

## 📊 Performance Profiling

### Profile App Performance
```bash
flutter run --profile
```

### Memory Profiling
```bash
flutter run -d <device> --profile
# Then use DevTools: http://localhost:8000
```

### Build Size Analysis
```bash
flutter build apk --release --analyze-size
```

## 🔐 Environment Variables

Create `.env` file:
```
GOOGLE_CLOUD_API_KEY=your-api-key
AZURE_TTS_KEY=your-azure-key
ML_MODEL_PATH=assets/models/isl_recognition_model.tflite
VOCABULARY_SIZE=100
CONFIDENCE_THRESHOLD=0.7
```

Load in Dart:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const BeethovenApp());
}
```

## 📚 Additional Resources

### Flutter Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### ML Frameworks
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [MediaPipe](https://mediapipe.dev/)
- [Riverpod](https://riverpod.dev/)

### ISL Resources
- [ISLAR Dataset](https://huggingface.co/datasets/akshaybahadur21/ISLAR)
- [ISL Gesture Recognition](https://github.com/akshaybahadur21/ISL_Recognition)

## 🎯 Next Steps

1. **Download Dataset**: Run `scripts/download_dataset.py`
2. **Train Model**: Run `scripts/train_model.py`
3. **Install Dependencies**: Run `flutter pub get`
4. **Run App**: Run `flutter run`
5. **Test Features**: Test camera and TTS functionality
6. **Deploy**: Build for iOS/Android

## ⚡ Quick Commands Reference

```bash
# Setup
flutter pub get
pip install -r scripts/requirements.txt

# Development
flutter run
flutter run --release
flutter run -d <device-id>

# Testing
flutter test
flutter test --coverage

# Build
flutter build apk --release
flutter build ios --release
flutter build web --release

# Clean
flutter clean
flutter pub cache clean

# Analysis
flutter analyze
dart format lib/
```

## 🆘 Getting Help

- Check [Flutter Issues](https://github.com/flutter/flutter/issues)
- Review [TensorFlow Lite Docs](https://www.tensorflow.org/lite/guide)
- Ask on [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- Open an issue on this repository

---

**Last Updated**: February 8, 2026  
**Maintainer**: ML Engineer, PhD MIT
