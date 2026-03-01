# Indian Sign Language to English Voice Conversion App
## ML-Powered Flutter Application

### Project Overview
A Flutter mobile/web application that uses machine learning to:
1. Capture live video from device camera
2. Detect and recognize Indian Sign Language gestures
3. Convert recognized signs to English text
4. Generate English speech with Indian accent

---

## Architecture

### 1. **Frontend (Flutter)**
- **Video Input**: Real-time camera feed using `camera` plugin
- **UI/UX**: Clean interface with live preview, translation display, audio playback
- **State Management**: Riverpod or GetX for reactive state

### 2. **Backend/ML Pipeline**
- **Model**: TensorFlow Lite model for ISL recognition
- **Dataset**: ISLAR from Hugging Face (https://huggingface.co/datasets/akshaybahadur21/ISLAR)
- **Framework**: TensorFlow/PyTorch for model training

### 3. **Text-to-Speech (TTS)**
- **Indian Accent**: Google Cloud Text-to-Speech or Microsoft Azure Speech Services
- **Alternative**: Open-source solutions like Festival or Espeak with Indian voice packs

---

## Tech Stack

### Mobile/Web Framework
```
Flutter 3.x
Dart
```

### ML/AI
```
TensorFlow Lite (for on-device inference)
MediaPipe (for pose detection - ISL uses hand/body poses)
OpenCV (via flutter_opencv or similar)
```

### APIs & Services
```
Google Cloud Text-to-Speech API (Indian English accent)
Firebase (optional - for cloud processing)
```

### Dependencies to Add
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.x
  tflite_flutter: ^0.9.x
  google_mlkit_pose_detection: ^0.13.x
  flutter_tts: ^0.12.x
  audio_session: ^0.1.x
  riverpod: ^2.x
  freezed_annotation: ^2.x
  
dev_dependencies:
  freezed: ^2.x
  build_runner: ^2.x
```

---

## Implementation Steps

### Phase 1: Setup & Preparation
1. ✅ Create Flutter project
2. ✅ Add camera and ML dependencies
3. Prepare ISL dataset from Hugging Face
4. Train/fine-tune TensorFlow Lite model for ISL recognition

### Phase 2: Model Development
1. **Dataset Preparation**
   - Download ISLAR dataset
   - Preprocess videos/images
   - Create train/validation/test splits
   
2. **Model Training**
   - Train action recognition model using:
     - 3D CNN (for video classification)
     - OR MediaPipe Pose + LSTM (for skeleton-based recognition)
   - Convert to TensorFlow Lite format for mobile deployment
   - Target: 85%+ accuracy on ISL vocabulary

3. **Model Optimization**
   - Quantization (int8/float16)
   - Pruning for faster inference
   - Target: <500ms inference time on mobile

### Phase 3: Flutter App Development

#### 3.1 Camera Module
```dart
// lib/features/camera/camera_screen.dart
- Real-time video capture
- Frame preprocessing
- Display FPS counter
```

#### 3.2 ML Inference Engine
```dart
// lib/features/ml/isL_interpreter.dart
- Load TensorFlow Lite model
- Preprocess frames (resize, normalize)
- Run inference on video frames
- Batch processing for accuracy
```

#### 3.3 Sign Language Recognition
```dart
// lib/features/recognition/sign_recognizer.dart
- Temporal analysis (last N frames)
- Confidence thresholding
- Gesture vocabulary management
```

#### 3.4 Text-to-Speech
```dart
// lib/features/tts/speech_service.dart
- Integration with Google Cloud TTS API
- Indian English accent selection
- Audio playback with flutter_tts
```

#### 3.5 UI Components
```dart
// lib/widgets/
- LiveCameraPreview
- TranslationDisplay
- ConfidenceBar
- HistoryPanel
```

### Phase 4: Integration & Testing
1. End-to-end testing
2. Performance optimization
3. Error handling & user feedback
4. Testing on multiple devices

---

## ISL Vocabulary Scope

### Initial Set (50 signs)
- Alphabets (A-Z)
- Numbers (0-9)
- Common words: hello, thank you, yes, no, please, sorry

### Extended Set (100+ signs)
- Daily phrases
- Common actions
- Frequently used gestures

---

## Data Flow

```
Camera Input (30 FPS)
    ↓
Frame Preprocessing (resize, normalize)
    ↓
TensorFlow Lite Model Inference
    ↓
Confidence Score & Sign Classification
    ↓
Text Output (ISL Sign → English Word)
    ↓
Google Cloud TTS API
    ↓
Audio Generation (Indian English accent)
    ↓
Audio Playback & Display
```

---

## API Integration Examples

### 1. Google Cloud Text-to-Speech (Recommended)
```dart
import 'package:google_cloud_flutter/google_cloud_flutter.dart';

Future<String> synthesizeSpeech(String text) async {
  final response = await GoogleTextToSpeech.synthesize(
    text: text,
    languageCode: 'en-IN',  // Indian English
    voiceGender: 'FEMALE',   // or MALE
    ssmlGender: 'FEMALE',
  );
  return response.audioContent;
}
```

### 2. Microsoft Azure Speech Services (Alternative)
```dart
// Uses Azure Cognitive Services
// Indian English voices: Neerja, PrabhatRanjan
```

### 3. Flutter TTS (Local - Less Natural)
```dart
final flutterTts = FlutterTts();
await flutterTts.setLanguage('en-IN');
await flutterTts.setSpeechRate(0.5);
await flutterTts.speak(recognizedText);
```

---

## Model Architecture Options

### Option 1: 3D CNN (Recommended for videos)
```
Input: Video frames (T, H, W, 3)
  ↓
3D Conv layers (extract spatio-temporal features)
  ↓
Temporal pooling
  ↓
Dense layers
  ↓
Output: ISL Sign class (softmax)
```

### Option 2: MediaPipe Pose + LSTM (Lightweight)
```
Input: Video frames
  ↓
MediaPipe Pose Detection (extract body landmarks)
  ↓
Landmark normalization
  ↓
LSTM/GRU layers (temporal modeling)
  ↓
Dense layer
  ↓
Output: ISL Sign class
```

**Recommendation**: Option 2 for mobile deployment (faster, lighter)

---

## Performance Metrics

### Target Metrics
- **Inference Speed**: <500ms per frame
- **Accuracy**: 85%+ on test set
- **Latency**: <1s for sign recognition + TTS
- **App Size**: <150MB
- **Memory Usage**: <300MB peak

---

## Development Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| Setup & Data Prep | Week 1 | Environment, dataset download |
| Model Training | Week 2-3 | Model development, optimization |
| Flutter App | Week 3-4 | Core app development |
| Integration | Week 5 | End-to-end integration |
| Testing & Optimization | Week 6 | Performance tuning, bug fixes |

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Limited ISL training data | Use data augmentation (rotation, scaling) |
| Real-time inference latency | Use MediaPipe Pose + LSTM for lightweight model |
| Lighting variations | Implement histogram equalization |
| Different user body types | Train on diverse dataset |
| TTS cost (Google Cloud) | Cache common phrases, use offline TTS fallback |
| App size | Quantize model, use dynamic delivery |

---

## Deployment

### Mobile (Android/iOS)
1. Build release APK/IPA
2. Test on multiple devices
3. Publish to Google Play Store / Apple App Store

### Web
1. Use `flutter web` build
2. Deploy to Firebase Hosting or Vercel
3. Handle browser limitations (camera permissions)

---

## Future Enhancements

1. **Offline Mode**: Download models and TTS voice packs
2. **Multi-language**: Support other sign languages (ASL, BSL)
3. **User Customization**: Adjust playback speed, accent preferences
4. **Community Feedback**: Crowd-sourced sign improvements
5. **Advanced Features**:
   - Sentence-level understanding
   - Context-aware translation
   - Video recording with captions
   - Statistics & learning progress

---

## Resources

### Datasets
- [ISLAR - Hugging Face](https://huggingface.co/datasets/akshaybahadur21/ISLAR)
- ISL Gesture Recognition Dataset (GitHub)

### Models & Code
- [MediaPipe](https://mediapipe.dev/) - Pose detection
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [TensorFlow Hub](https://tfhub.dev/) - Pre-trained models

### APIs
- [Google Cloud Text-to-Speech](https://cloud.google.com/text-to-speech)
- [Microsoft Azure Speech](https://azure.microsoft.com/en-us/services/cognitive-services/text-to-speech/)

### Flutter Packages
- `camera` - Video capture
- `tflite_flutter` - ML inference
- `google_mlkit_pose_detection` - Pose estimation
- `flutter_tts` - Text-to-speech

---

## Getting Started Commands

```bash
# Create new Flutter project
flutter create --platforms=android,ios,web isl_translator

# Add dependencies
flutter pub add camera tflite_flutter google_mlkit_pose_detection flutter_tts

# Run on device
flutter run

# Build for release
flutter build apk --release
flutter build ios --release
```

---

**Author**: ML Engineer, PhD MIT  
**Status**: Project Specification  
**Last Updated**: February 8, 2026
