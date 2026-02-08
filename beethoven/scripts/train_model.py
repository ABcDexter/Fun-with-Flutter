"""
ISL Model Training Script
Trains a 3D CNN and MediaPipe-based LSTM models for Indian Sign Language recognition
Using the ISLAR dataset from Hugging Face
"""

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import mediapipe as mp
from sklearn.model_selection import train_test_split
from datasets import load_dataset
import cv2
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

# ============================================================================
# Data Loading & Preprocessing
# ============================================================================

def load_islar_dataset():
    """Load ISLAR dataset from Hugging Face"""
    print("Loading ISLAR dataset from Hugging Face...")
    dataset = load_dataset("akshaybahadur21/ISLAR")
    return dataset

def extract_poses_mediapipe(video_path):
    """
    Extract hand and pose landmarks using MediaPipe
    Returns: Array of shape (seq_length, 33*3) for pose landmarks
    """
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

def preprocess_dataset(dataset, model_type="lstm_mediapipe"):
    """Preprocess the dataset"""
    X = []
    y = []
    
    print(f"Preprocessing {len(dataset)} samples...")
    for idx, sample in enumerate(tqdm(dataset)):
        video_path = sample['video']
        label = sample['label']
        
        try:
            if model_type == "lstm_mediapipe":
                poses = extract_poses_mediapipe(video_path)
                X.append(poses)
            else:  # 3dcnn
                frames = extract_frames_3dcnn(video_path)
                X.append(frames)
            
            y.append(label)
        except Exception as e:
            print(f"Error processing {video_path}: {e}")
            continue
    
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

if __name__ == "__main__":
    print("=" * 70)
    print("Indian Sign Language Recognition Model Training")
    print("=" * 70)
    
    # Load dataset
    dataset = load_islar_dataset()
    print(f"Loaded {len(dataset)} samples")
    
    # Preprocess
    X, y = preprocess_dataset(dataset, model_type=MODEL_TYPE)
    
    # Train
    model, history = train_model(X, y, model_type=MODEL_TYPE)
    
    # Convert to TFLite
    convert_to_tflite(model, output_path='isl_recognition_model.tflite')
    
    print("\nTraining completed successfully!")
