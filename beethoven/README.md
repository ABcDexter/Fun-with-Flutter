# Beethoven

Indian Sign Language to text and speech using Flutter plus TensorFlow.

## Overview

`Beethoven` currently runs a web camera pipeline that:

- captures live frames in Flutter Web
- detects hand regions using MediaPipe Hands
- crops and normalizes hand regions to `224x224`
- applies temporal smoothing over 7 frames for stability
- sends processed frames to a TensorFlow.js image classifier
- performs sign segmentation by detecting sign start/end based on confidence
- builds sentences by accumulating completed signs
- maps predictions through `label_map.json`
- shows current sign, confidence, and full sentence in the UI
- provides text-to-speech output for recognized signs

The current web flow uses a **hand-cropped 2D classifier with temporal processing**, supporting real-time sentence formation from continuous signing.

## Runtime Flow

```mermaid
flowchart TD
    A[Camera Frame Capture] --> B[MediaPipe Hands Detection]
    B --> C{Hand Detected?}
    C -->|No| D[Full Frame Processing]
    C -->|Yes| E[Crop Hand Region]
    D --> F[Resize to 224x224]
    E --> F
    F --> G[Normalize RGB [0,1]]
    G --> H[Apply 7-Frame Temporal Smoothing]
    H --> I[TFJS Model Inference]
    I --> J{Confidence > Threshold?}
    J -->|No| K[Increment Low Confidence Counter]
    J -->|Yes| L[Set Current Sign]
    K --> M{Counter > 10 Frames?}
    M -->|No| N[Continue Processing]
    M -->|Yes| O[Add Sign to Sentence]
    L --> N
    O --> P[Reset Counters]
    P --> N
    N --> Q[Update UI: Current Sign + Sentence]
    Q --> A
```

This flowchart shows the complete pipeline from camera input to sentence output, including hand detection, temporal smoothing, sign segmentation, and sentence building.

## Current Status

### Web inference

- **Runtime model:** `web/models/isl_tfjs/model.json`
- **Runtime labels:** `web/models/isl_tfjs/label_map.json`
- **Input shape:** `[batch, 224, 224, 3]`
- **Preprocessing:** RGB float32 in `[0, 1]`
- **Threshold:** `0.4` in `lib/config/constants.dart`
- **Inference screen:** `lib/features/ui/camera_screen_web.dart`

### Speech output

- **Current implementation:** `flutter_tts` via `lib/services/tts_service.dart`
- **Current locale:** `en-IN`
- **Planned provider:** `Sarvam AI Text-to-Speech`

`Sarvam` is not wired into the app yet. The codebase still uses `flutter_tts` today.

## Why accuracy can be low right now

If a sign like `1` is predicted as `l`, the most likely reasons are:

- **Visual similarity:** `1` and `l` are extremely close in static hand shape, especially in a single frame.
- **Single-frame model:** the current web model does not use motion or temporal context.
- **Domain shift:** the training dataset and your webcam feed likely differ in lighting, background, framing, hand distance, and camera angle.
- **No hand crop:** the app currently sends the full frame, not a cropped hand region, so the model sees a lot of irrelevant background.
- **Quick training run:** a short run like `5` epochs on `5000` samples is useful for smoke validation, but often not enough for robust webcam accuracy.
- **Class balance / label quality:** some classes may have fewer or noisier examples than others.
- **Hand orientation mismatch:** left-hand vs right-hand usage, mirrored camera views, and rotation can all reduce accuracy.
- **Threshold is not the root cause:** lowering threshold changes whether you show a prediction, but does not make the prediction more correct.

## Recommended next improvements

To improve real-world accuracy, prioritize these changes:

1. **Train longer on more data**
    - use the full dataset or a much larger subset
    - increase epochs
    - monitor validation accuracy and confusion between similar classes

2. **Add hand detection or cropping**
    - crop around the hand before inference
    - reduce background noise

3. **Use stronger augmentation**
    - brightness, contrast, zoom, translation, mild rotation
    - horizontal flip only if it is valid for your label semantics

4. **Check label confusion pairs**
    - especially `1` vs `l`, and other visually similar signs
    - inspect a confusion matrix after training

5. **Consider temporal modeling later**
    - for dynamic signs, move back to a temporal model only after the image pipeline is stable

## Project structure

```text
beethoven/
├── lib/
│   ├── config/
│   │   └── constants.dart
│   ├── features/ui/
│   │   ├── camera_screen_web.dart
│   │   └── home_screen.dart
│   ├── services/
│   │   ├── ml_service_mobile.dart
│   │   ├── ml_service_web.dart
│   │   └── tts_service.dart
│   └── main.dart
├── scripts/
│   ├── train_isl_classifier.py
│   ├── smoke_train_isl_classifier.py
│   └── requirements.txt
├── saved_model_islar/
├── web/
│   ├── isl_tfjs.js
│   └── models/isl_tfjs/
├── assets/
└── pubspec.yaml
```

## Quick start

### Flutter app

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
flutter pub get
flutter run -d chrome
```

### Python environment

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
python3 -m venv .venv
source .venv/bin/activate
pip install -r scripts/requirements.txt
```

## Training workflow

### Smoke check

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
python smoke_train_isl_classifier.py
```

This only verifies the model builds and runs a forward pass.

### Train the image classifier

From the repository root:

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
source .venv/bin/activate
python scripts/train_isl_classifier.py \
  --epochs 12 \
  --batch_size 32 \
  --max_samples 0 \
  --export_tfjs
```

### Quick experimental run

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
source .venv/bin/activate
python scripts/train_isl_classifier.py \
  --epochs 5 \
  --batch_size 16 \
  --max_samples 5000 \
  --export_tfjs
```

## Important path note

`train_isl_classifier.py` resolves relative paths from the `scripts/` directory.

That means:

- the default `--tfjs_output_dir` already points to `../web/models/isl_tfjs`
- if you pass `web/models/isl_tfjs`, it may export into `scripts/web/models/isl_tfjs` instead of the app's real web folder

If needed, copy outputs into:

```zsh
cp -r scripts/web/models/isl_tfjs/* web/models/isl_tfjs/
cp saved_model_islar/label_map.json web/models/isl_tfjs/
```

## Web model loading details

For Flutter Web, the app loads:

- `model.json` through `web/isl_tfjs.js`
- `label_map.json` over HTTP from `models/isl_tfjs/label_map.json`

This is why `label_map.json` must exist inside `web/models/isl_tfjs/`.

## Current inference logic

The web camera screen in `lib/features/ui/camera_screen_web.dart`:

- opens the camera with `getUserMedia`
- draws the current frame to a hidden canvas
- extracts normalized RGB pixels
- runs TFJS inference through `lib/services/ml_service_web.dart`
- chooses the highest probability class
- shows the label if confidence exceeds `MLModelConstants.confidenceThreshold`

## TTS roadmap

### Current

- `flutter_tts`
- Indian English locale: `en-IN`

### Planned: Sarvam AI TTS

Target API:

- `https://www.sarvam.ai/apis/text-to-speech/`

Planned integration approach:

1. send recognized text to a backend or secure API client
2. request speech audio from `Sarvam`
3. play returned audio in Flutter
4. keep `flutter_tts` as a local fallback during development if needed

### Suggested config for future Sarvam integration

Do not hardcode secrets in Flutter web code. Prefer a backend proxy or protected environment.

Possible environment variables for a backend service:

```text
SARVAM_API_KEY=
SARVAM_TTS_VOICE=
SARVAM_TTS_LANGUAGE_CODE=
```

## Known limitations

- web path currently uses frame-by-frame classification only
- no explicit hand detector or cropper yet
- no confusion-matrix-based evaluation workflow documented in app
- `numberOfClasses` in `lib/config/constants.dart` still reflects older assumptions and may need cleanup
- README reflects current behavior more accurately than older architecture docs that mention MediaPipe or 3D-CNN web inference

## Testing

### Flutter tests

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
flutter test
```

### Run the web app

```zsh
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven
flutter run -d chrome
```

## TODOs (Clear Roadmap)

### ✅ Done

- [x] Web inference switched to single-frame TFJS classifier
- [x] `label_map.json` loading added for class-name mapping
- [x] MediaPipe Hands integrated for hand-region detection
- [x] Hand crop + normalization applied before inference
- [x] Prediction smoothing window added
- [x] Debug badge + hand bounding box overlay added
- [x] Sign segmentation with confidence-based sign end detection
- [x] Sentence builder that accumulates completed signs
- [x] Real-time sentence display with clear button

### 🔥 High Priority (Next)

- [ ] Align class constants in app (`100` vs `41`) across config/UI/docs
- [ ] Add confusion-matrix evaluation script/report for `1` vs `l` and similar pairs
- [ ] Retrain with larger/full dataset + longer schedule (not just smoke-size run)
- [ ] Tune threshold and smoothing window with validation metrics
- [ ] Add option to require `2` hands for two-hand signs before prediction

### 🧪 Model Quality TODOs

- [ ] Add stronger augmentation (lighting, contrast, slight rotation/translation)
- [ ] Add hard-negative samples (no hand / background-only frames)
- [ ] Evaluate per-class precision/recall and identify weak labels
- [ ] Add validation script for webcam-domain performance

### 🎙️ TTS TODOs

- [ ] Integrate `Sarvam` TTS API through a secure backend/proxy
- [ ] Keep `flutter_tts` as fallback when API is unavailable
- [ ] Add voice/language config for runtime switching

### 🧹 Cleanup TODOs

- [ ] Remove stale README sections that mention deprecated pipelines
- [ ] Add architecture diagram for current MediaPipe + TFJS flow
- [ ] Add reproducible training presets (`fast`, `balanced`, `full`)

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

### Phase 0: MVP (Current)
- Basic sign recognition

### Phase 1: MVP (Next)
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
