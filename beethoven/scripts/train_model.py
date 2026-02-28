"""
ISL Model Training Script
Trains a 3D CNN and MediaPipe-based LSTM models for Indian Sign Language recognition
Using the ISLAR dataset from Hugging Face
"""

import argparse
import io
import os
from typing import Any, Iterable

import cv2
import mediapipe as mp
import numpy as np
import tensorflow as tf
from datasets import load_dataset, load_from_disk
from PIL import Image
from sklearn.model_selection import train_test_split
from tensorflow import keras
from tensorflow.keras import layers
from tqdm import tqdm

# ============================================================================
# Configuration
# ============================================================================

MODEL_TYPE = "lstm_mediapipe"  # Options: "3dcnn" or "lstm_mediapipe"
VOCABULARY_SIZE = 100
SEQUENCE_LENGTH = 30  # frames per gesture
IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 0.001
TEST_SIZE = 0.2
VAL_SIZE = 0.2
DATASET_NAME = "akshaybahadur21/ISLAR"
DATASET_SPLIT = "train"
LOCAL_DATASET_DIR = os.getenv("ISLAR_DATASET_DIR", "")

# ============================================================================
# Data Loading & Preprocessing
# ============================================================================

def load_islar_dataset():
    """Load ISLAR dataset from Hugging Face or a local saved dataset."""
    if LOCAL_DATASET_DIR:
        dataset_path = os.path.expanduser(LOCAL_DATASET_DIR)
        print(f"Loading ISLAR dataset from disk: {dataset_path}")
        return load_from_disk(dataset_path)

    print("Loading ISLAR dataset from Hugging Face...")
    return load_dataset(DATASET_NAME)


def select_dataset_split(dataset, split: str):
    """Return a Dataset split from a DatasetDict or passthrough Dataset."""
    if hasattr(dataset, "keys"):
        if split in dataset:
            return dataset[split]
        return next(iter(dataset.values()))
    return dataset


def resolve_column_name(dataset, candidates: Iterable[str]) -> str:
    """Pick the first matching column from candidates."""
    for name in candidates:
        if name in dataset.column_names:
            return name
    raise ValueError(
        f"None of the candidate columns {list(candidates)} exist in dataset columns {dataset.column_names}."
    )


def resolve_video_path(video_value: Any) -> str:
    """Resolve video path from dataset field value."""
    if isinstance(video_value, dict):
        if "path" in video_value:
            return video_value["path"]
        if "file" in video_value:
            return video_value["file"]
    return video_value


def resolve_image_array(image_value: Any) -> np.ndarray:
    if isinstance(image_value, dict):
        if "array" in image_value:
            return np.array(image_value["array"])
        if "bytes" in image_value:
            return np.array(Image.open(io.BytesIO(image_value["bytes"])).convert("RGB"))
        if "path" in image_value:
            return np.array(Image.open(image_value["path"]).convert("RGB"))
    if isinstance(image_value, Image.Image):
        return np.array(image_value.convert("RGB"))
    if isinstance(image_value, np.ndarray):
        return image_value
    raise ValueError("Unsupported image value type for dataset 'image' column.")


def ensure_mediapipe_available():
    if not hasattr(mp, "solutions"):
        raise RuntimeError(
            "mediapipe module does not expose 'solutions'. "
            "This usually indicates a bad install or a conflicting package. "
            "Reinstall mediapipe in the active venv or use --model_type 3dcnn."
        )

def extract_poses_mediapipe(video_path):
    """
    Extract hand and pose landmarks using MediaPipe
    Returns: Array of shape (seq_length, 33*3) for pose landmarks
    """
    ensure_mediapipe_available()
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(static_image_mode=False, min_detection_confidence=0.5)
    
    cap = cv2.VideoCapture(video_path)
    frames = []
    pose_sequence = []
    
    while len(pose_sequence) < SEQUENCE_LENGTH:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(frame_rgb)
        
        if results.pose_landmarks:
            # Extract landmarks (33 landmarks * 3 coordinates = 99 values)
            landmarks = []
            for lm in results.pose_landmarks.landmark:
                landmarks.extend([lm.x, lm.y, lm.z])
            pose_sequence.append(landmarks)
    
    cap.release()
    
    # Pad sequence if needed
    if len(pose_sequence) < SEQUENCE_LENGTH:
        padding = np.zeros((SEQUENCE_LENGTH - len(pose_sequence), 99))
        pose_sequence = np.vstack([pose_sequence, padding])
    else:
        pose_sequence = pose_sequence[:SEQUENCE_LENGTH]
    
    return np.array(pose_sequence)


def extract_pose_from_image(image_array: np.ndarray) -> np.ndarray:
    ensure_mediapipe_available()
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5)
    if image_array.shape[-1] == 4:
        image_array = cv2.cvtColor(image_array, cv2.COLOR_RGBA2RGB)
    results = pose.process(image_array)

    if results.pose_landmarks:
        landmarks = []
        for lm in results.pose_landmarks.landmark:
            landmarks.extend([lm.x, lm.y, lm.z])
        return np.array(landmarks)

    return np.zeros(99)

def extract_frames_3dcnn(video_path):
    """
    Extract frames for 3D CNN model
    Returns: Array of shape (seq_length, height, width, 3)
    """
    cap = cv2.VideoCapture(video_path)
    frames = []
    
    while len(frames) < SEQUENCE_LENGTH:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Resize frame
        frame = cv2.resize(frame, (IMG_SIZE, IMG_SIZE))
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        frame = frame / 255.0  # Normalize
        frames.append(frame)
    
    cap.release()
    
    # Pad sequence if needed
    if len(frames) < SEQUENCE_LENGTH:
        padding = np.zeros((SEQUENCE_LENGTH - len(frames), IMG_SIZE, IMG_SIZE, 3))
        frames = np.vstack([frames, padding])
    else:
        frames = frames[:SEQUENCE_LENGTH]
    
    return np.array(frames)


def extract_frames_from_image(image_array: np.ndarray) -> np.ndarray:
    if image_array.shape[-1] == 4:
        image_array = cv2.cvtColor(image_array, cv2.COLOR_RGBA2RGB)
    frame = cv2.resize(image_array, (IMG_SIZE, IMG_SIZE))
    frame = frame / 255.0
    return np.stack([frame] * SEQUENCE_LENGTH)

def preprocess_dataset(dataset, model_type="lstm_mediapipe"):
    """Preprocess the dataset"""
    X = []
    y = []

    if model_type == "lstm_mediapipe":
        ensure_mediapipe_available()

    dataset = select_dataset_split(dataset, DATASET_SPLIT)
    label_column = resolve_column_name(dataset, ["label", "labels", "class", "category", "target"])
    uses_image_column = "image" in dataset.column_names
    video_column = None if uses_image_column else resolve_column_name(
        dataset, ["video", "video_path", "path", "file", "filepath"]
    )

    print(f"Preprocessing {len(dataset)} samples...")
    failed = 0
    for idx, sample in enumerate(tqdm(dataset)):
        label = sample[label_column]
        if uses_image_column:
            image_array = resolve_image_array(sample["image"])
        else:
            video_path = resolve_video_path(sample[video_column])
        
        try:
            if model_type == "lstm_mediapipe":
                if uses_image_column:
                    pose = extract_pose_from_image(image_array)
                    poses = np.stack([pose] * SEQUENCE_LENGTH)
                else:
                    poses = extract_poses_mediapipe(video_path)
                X.append(poses)
            else:  # 3dcnn
                if uses_image_column:
                    frames = extract_frames_from_image(image_array)
                else:
                    frames = extract_frames_3dcnn(video_path)
                X.append(frames)
            
            y.append(label)
        except Exception as e:
            source = "image" if uses_image_column else video_path
            print(f"Error processing {source}: {e}")
            failed += 1
            continue
    
    if len(X) == 0:
        raise RuntimeError(
            "No samples were processed successfully. "
            "Check mediapipe installation or try --model_type 3dcnn for image-only datasets."
        )

    if failed:
        print(f"Skipped {failed} samples due to preprocessing errors.")

    return np.array(X), np.array(y)

# ============================================================================
# Model Architecture
# ============================================================================

def build_lstm_mediapipe_model(input_shape, num_classes):
    """
    Build LSTM model for MediaPipe pose sequences
    Input shape: (seq_length, 99) where 99 = 33 landmarks * 3 coordinates
    """
    model = keras.Sequential([
        layers.Input(shape=input_shape),
        
        # First LSTM layer
        layers.LSTM(64, activation='relu', return_sequences=True),
        layers.Dropout(0.2),
        
        # Second LSTM layer
        layers.LSTM(32, activation='relu', return_sequences=False),
        layers.Dropout(0.2),
        
        # Dense layers
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(64, activation='relu'),
        layers.Dropout(0.2),
        
        # Output layer
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

def build_3dcnn_model(input_shape, num_classes):
    """
    Build 3D CNN model for video frames
    Input shape: (seq_length, height, width, 3)
    """
    model = keras.Sequential([
        layers.Input(shape=input_shape),
        
        # 3D Convolutional layers
        layers.Conv3D(32, (3, 3, 3), activation='relu', padding='same'),
        layers.MaxPooling3D((2, 2, 2)),
        layers.Dropout(0.2),
        
        layers.Conv3D(64, (3, 3, 3), activation='relu', padding='same'),
        layers.MaxPooling3D((2, 2, 2)),
        layers.Dropout(0.2),
        
        layers.Conv3D(128, (3, 3, 3), activation='relu', padding='same'),
        layers.MaxPooling3D((2, 2, 2)),
        layers.Dropout(0.3),
        
        # Flatten and dense layers
        layers.Flatten(),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.2),
        
        # Output layer
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

# ============================================================================
# Training
# ============================================================================

def train_model(X, y, model_type="lstm_mediapipe"):
    """Train the ISL recognition model"""
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=TEST_SIZE, random_state=42
    )
    
    X_train, X_val, y_train, y_val = train_test_split(
        X_train, y_train, test_size=VAL_SIZE, random_state=42
    )
    
    # Normalize labels
    from tensorflow.keras.utils import to_categorical
    y_train_cat = to_categorical(y_train, VOCABULARY_SIZE)
    y_val_cat = to_categorical(y_val, VOCABULARY_SIZE)
    y_test_cat = to_categorical(y_test, VOCABULARY_SIZE)
    
    # Build model
    if model_type == "lstm_mediapipe":
        input_shape = (SEQUENCE_LENGTH, 99)  # 33 landmarks * 3
        model = build_lstm_mediapipe_model(input_shape, VOCABULARY_SIZE)
    else:
        input_shape = (SEQUENCE_LENGTH, IMG_SIZE, IMG_SIZE, 3)
        model = build_3dcnn_model(input_shape, VOCABULARY_SIZE)
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss='categorical_crossentropy',
        metrics=['accuracy', keras.metrics.TopKCategoricalAccuracy(k=5, name='top_5_accuracy')]
    )
    
    # Callbacks
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=0.00001
        ),
        keras.callbacks.ModelCheckpoint(
            f'best_model_{model_type}.h5',
            monitor='val_accuracy',
            save_best_only=True
        ),
    ]
    
    # Train model
    print(f"\nTraining {model_type} model...")
    history = model.fit(
        X_train, y_train_cat,
        validation_data=(X_val, y_val_cat),
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate
    print("\nEvaluating model...")
    eval_results = model.evaluate(X_test, y_test_cat, verbose=0)
    print(f"Test Loss: {eval_results[0]:.4f}")
    print(f"Test Accuracy: {eval_results[1]:.4f}")
    print(f"Test Top-5 Accuracy: {eval_results[2]:.4f}")
    
    return model, history

# ============================================================================
# Convert to TensorFlow Lite
# ============================================================================

def convert_to_tflite(model, output_path='isl_recognition_model.tflite'):
    """Convert Keras model to TensorFlow Lite format"""
    print(f"\nConverting model to TensorFlow Lite...")
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Model saved to {output_path}")
    return tflite_model

# ============================================================================
# Main Training Pipeline
# ============================================================================

def parse_args():
    parser = argparse.ArgumentParser(description="Train ISL recognition model")
    parser.add_argument("--model_type", default=MODEL_TYPE, choices=["lstm_mediapipe", "3dcnn"])
    parser.add_argument("--vocabulary_size", type=int, default=VOCABULARY_SIZE)
    parser.add_argument("--sequence_length", type=int, default=SEQUENCE_LENGTH)
    parser.add_argument("--epochs", type=int, default=EPOCHS)
    parser.add_argument("--dataset_name", default=DATASET_NAME)
    parser.add_argument("--dataset_split", default=DATASET_SPLIT)
    parser.add_argument("--dataset_dir", default=LOCAL_DATASET_DIR)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    MODEL_TYPE = args.model_type
    VOCABULARY_SIZE = args.vocabulary_size
    SEQUENCE_LENGTH = args.sequence_length
    EPOCHS = args.epochs
    DATASET_NAME = args.dataset_name
    DATASET_SPLIT = args.dataset_split
    LOCAL_DATASET_DIR = args.dataset_dir

    print("=" * 70)
    print("Indian Sign Language Recognition Model Training")
    print("=" * 70)
    
    # Load dataset
    dataset = load_islar_dataset()
    dataset_split = select_dataset_split(dataset, DATASET_SPLIT)
    if "label" in dataset_split.features:
        label_feature = dataset_split.features["label"]
        if hasattr(label_feature, "num_classes"):
            VOCABULARY_SIZE = max(VOCABULARY_SIZE, label_feature.num_classes)
    print(f"Loaded {len(dataset_split)} samples")
    
    # Preprocess
    X, y = preprocess_dataset(dataset, model_type=MODEL_TYPE)
    
    # Train
    model, history = train_model(X, y, model_type=MODEL_TYPE)
    
    # Convert to TFLite
    convert_to_tflite(model, output_path='isl_recognition_model.tflite')
    
    print("\nTraining completed successfully!")
