"""
Train an ISL image classifier aligned with runtime preprocessing.

Key goals:
- Uses ISLAR labels directly (defaults to 41 classes from dataset metadata)
- Keeps runtime-compatible input: RGB 224x224 float32 in [0, 1]
- Saves label mapping JSON for app-side class-name lookup
- Exports SavedModel + optional TFLite + optional TFJS
"""

from __future__ import annotations

import argparse
import io
import json
import random
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

import numpy as np
import tensorflow as tf
from datasets import Dataset, load_dataset, load_from_disk
from PIL import Image
from sklearn.model_selection import train_test_split


@dataclass
class TrainConfig:
    dataset_name: str
    dataset_split: str
    local_dataset_dir: str
    output_dir: str
    model_name: str
    img_size: int
    batch_size: int
    epochs: int
    learning_rate: float
    val_size: float
    test_size: float
    seed: int
    max_samples: int
    cache_dir: str
    export_tflite: bool
    export_tfjs: bool
    tfjs_output_dir: str


def parse_args() -> TrainConfig:
    parser = argparse.ArgumentParser(description="Train ISL classifier on ISLAR dataset")
    parser.add_argument("--dataset_name", default="akshaybahadur21/ISLAR")
    parser.add_argument("--dataset_split", default="train")
    parser.add_argument("--local_dataset_dir", default="")
    parser.add_argument("--output_dir", default="../saved_model_islar")
    parser.add_argument("--model_name", default="mobilenetv3_small")
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--epochs", type=int, default=12)
    parser.add_argument("--learning_rate", type=float, default=1e-3)
    parser.add_argument("--val_size", type=float, default=0.1)
    parser.add_argument("--test_size", type=float, default=0.1)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--max_samples", type=int, default=0, help="0 means full dataset")
    parser.add_argument("--cache_dir", default="")
    parser.add_argument("--export_tflite", action="store_true")
    parser.add_argument("--export_tfjs", action="store_true")
    parser.add_argument("--tfjs_output_dir", default="../web/models/isl_tfjs")
    args = parser.parse_args()

    return TrainConfig(
        dataset_name=args.dataset_name,
        dataset_split=args.dataset_split,
        local_dataset_dir=args.local_dataset_dir,
        output_dir=args.output_dir,
        model_name=args.model_name,
        img_size=args.img_size,
        batch_size=args.batch_size,
        epochs=args.epochs,
        learning_rate=args.learning_rate,
        val_size=args.val_size,
        test_size=args.test_size,
        seed=args.seed,
        max_samples=args.max_samples,
        cache_dir=args.cache_dir,
        export_tflite=args.export_tflite,
        export_tfjs=args.export_tfjs,
        tfjs_output_dir=args.tfjs_output_dir,
    )


def set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    tf.random.set_seed(seed)


def resolve_path(path_value: str) -> Path:
    path = Path(path_value).expanduser()
    if path.is_absolute():
        return path
    script_dir = Path(__file__).resolve().parent
    return (script_dir / path).resolve()


def load_islar_dataset(config: TrainConfig):
    if config.local_dataset_dir:
        path = resolve_path(config.local_dataset_dir)
        print(f"Loading dataset from disk: {path}")
        return load_from_disk(str(path))

    print(f"Loading dataset from Hugging Face: {config.dataset_name}")
    kwargs = {}
    if config.cache_dir:
        kwargs["cache_dir"] = config.cache_dir
    return load_dataset(config.dataset_name, **kwargs)


def select_dataset_split(dataset_obj: Any, split: str) -> Dataset:
    if hasattr(dataset_obj, "keys"):
        if split in dataset_obj:
            return dataset_obj[split]
        return next(iter(dataset_obj.values()))
    return dataset_obj


def resolve_column_name(dataset: Dataset, candidates: Iterable[str]) -> str:
    for name in candidates:
        if name in dataset.column_names:
            return name
    raise ValueError(f"None of {list(candidates)} found in columns {dataset.column_names}")


def image_to_rgb_array(image_value: Any) -> np.ndarray:
    if isinstance(image_value, dict):
        if "array" in image_value and image_value["array"] is not None:
            arr = np.array(image_value["array"])
            if arr.ndim == 3:
                if arr.shape[-1] == 4:
                    arr = arr[..., :3]
                return arr
        if "bytes" in image_value and image_value["bytes"] is not None:
            pil = Image.open(io.BytesIO(image_value["bytes"]))
            return np.array(pil.convert("RGB"))
        if "path" in image_value and image_value["path"]:
            pil = Image.open(image_value["path"])
            return np.array(pil.convert("RGB"))

    if isinstance(image_value, Image.Image):
        return np.array(image_value.convert("RGB"))

    if isinstance(image_value, np.ndarray):
        if image_value.ndim == 3 and image_value.shape[-1] == 4:
            return image_value[..., :3]
        return image_value

    raise ValueError("Unsupported image sample format")


def build_xy_arrays(dataset: Dataset, img_size: int, max_samples: int) -> tuple[np.ndarray, np.ndarray]:
    label_col = resolve_column_name(dataset, ["label", "labels", "class", "target", "category"])
    if "image" not in dataset.column_names:
        raise ValueError("Dataset must contain an 'image' column for this trainer")

    total = len(dataset)
    if max_samples > 0:
        total = min(total, max_samples)

    x_data: list[np.ndarray] = []
    y_data: list[int] = []

    for index in range(total):
        sample = dataset[index]
        image_arr = image_to_rgb_array(sample["image"])
        resized = tf.image.resize(image_arr, (img_size, img_size), method="bilinear").numpy()
        normalized = np.clip(resized, 0, 255).astype(np.float32) / 255.0

        x_data.append(normalized)
        y_data.append(int(sample[label_col]))

        if (index + 1) % 2000 == 0:
            print(f"Processed {index + 1}/{total} samples")

    x_array = np.stack(x_data).astype(np.float32)
    y_array = np.array(y_data, dtype=np.int32)
    return x_array, y_array


def resolve_class_names(dataset: Dataset, y: np.ndarray) -> list[str]:
    label_feature = dataset.features.get("label") if hasattr(dataset, "features") else None
    if label_feature is not None and hasattr(label_feature, "names") and label_feature.names:
        return list(label_feature.names)

    num_classes = int(y.max()) + 1
    return [str(index) for index in range(num_classes)]


def split_data(
    x: np.ndarray,
    y: np.ndarray,
    test_size: float,
    val_size: float,
    seed: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    x_train_val, x_test, y_train_val, y_test = train_test_split(
        x,
        y,
        test_size=test_size,
        random_state=seed,
        stratify=y,
    )

    relative_val_size = val_size / (1.0 - test_size)
    x_train, x_val, y_train, y_val = train_test_split(
        x_train_val,
        y_train_val,
        test_size=relative_val_size,
        random_state=seed,
        stratify=y_train_val,
    )

    return x_train, y_train, x_val, y_val, x_test, y_test


def make_tf_dataset(x: np.ndarray, y: np.ndarray, batch_size: int, training: bool) -> tf.data.Dataset:
    ds = tf.data.Dataset.from_tensor_slices((x, y))
    if training:
        ds = ds.shuffle(min(8192, len(x)))
        augmenter = tf.keras.Sequential(
            [
                tf.keras.layers.RandomFlip("horizontal"),
                tf.keras.layers.RandomRotation(0.05),
                tf.keras.layers.RandomZoom(0.08),
            ]
        )

        ds = ds.map(lambda img, label: (augmenter(img, training=True), label), num_parallel_calls=tf.data.AUTOTUNE)

    ds = ds.batch(batch_size).prefetch(tf.data.AUTOTUNE)
    return ds


def build_model(model_name: str, img_size: int, num_classes: int) -> tf.keras.Model:
    input_layer = tf.keras.layers.Input(shape=(img_size, img_size, 3), name="input_rgb_0_1")

    if model_name == "mobilenetv3_small":
        backbone = tf.keras.applications.MobileNetV3Small(
            include_top=False,
            weights="imagenet",
            input_shape=(img_size, img_size, 3),
            pooling="avg",
            dropout_rate=0.0,
        )
        x = tf.keras.layers.Rescaling(scale=255.0)(input_layer)
        x = tf.keras.layers.Lambda(tf.keras.applications.mobilenet_v3.preprocess_input)(x)
    elif model_name == "efficientnetb0":
        backbone = tf.keras.applications.EfficientNetB0(
            include_top=False,
            weights="imagenet",
            input_shape=(img_size, img_size, 3),
            pooling="avg",
        )
        x = tf.keras.layers.Rescaling(scale=255.0)(input_layer)
        x = tf.keras.layers.Lambda(tf.keras.applications.efficientnet.preprocess_input)(x)
    else:
        raise ValueError("Unsupported model_name. Use 'mobilenetv3_small' or 'efficientnetb0'.")

    backbone.trainable = False
    x = backbone(x, training=False)
    x = tf.keras.layers.Dropout(0.3)(x)
    output = tf.keras.layers.Dense(num_classes, activation="softmax", name="probs")(x)

    model = tf.keras.Model(inputs=input_layer, outputs=output, name=f"isl_{model_name}")
    return model


def train_model(
    model: tf.keras.Model,
    train_ds: tf.data.Dataset,
    val_ds: tf.data.Dataset,
    learning_rate: float,
    epochs: int,
) -> tf.keras.callbacks.History:
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy", tf.keras.metrics.SparseTopKCategoricalAccuracy(k=3, name="top3")],
    )

    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_accuracy", patience=4, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=2),
    ]

    history = model.fit(train_ds, validation_data=val_ds, epochs=epochs, callbacks=callbacks)

    for layer in model.layers:
        if isinstance(layer, tf.keras.Model):
            layer.trainable = True

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate * 0.1),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy", tf.keras.metrics.SparseTopKCategoricalAccuracy(k=3, name="top3")],
    )

    fine_tune_epochs = max(2, epochs // 3)
    model.fit(train_ds, validation_data=val_ds, epochs=fine_tune_epochs, callbacks=callbacks)
    return history


def save_label_artifacts(class_names: list[str], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    id_to_label = {str(index): name for index, name in enumerate(class_names)}
    label_to_id = {name: index for index, name in enumerate(class_names)}

    with (output_dir / "label_map.json").open("w", encoding="utf-8") as file:
        json.dump(
            {
                "num_classes": len(class_names),
                "id_to_label": id_to_label,
                "label_to_id": label_to_id,
            },
            file,
            indent=2,
            ensure_ascii=False,
        )


def export_tflite_model(model: tf.keras.Model, output_dir: Path) -> Path:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_bytes = converter.convert()
    tflite_path = output_dir / "isl_classifier.tflite"
    tflite_path.write_bytes(tflite_bytes)
    return tflite_path


def export_tfjs_model(saved_model_dir: Path, tfjs_output_dir: Path) -> bool:
    converter = shutil.which("tensorflowjs_converter")
    if not converter:
        print("tensorflowjs_converter not found; skipping TFJS export")
        return False

    tfjs_output_dir.mkdir(parents=True, exist_ok=True)
    command = [
        converter,
        "--input_format",
        "tf_saved_model",
        "--output_format",
        "tfjs_graph_model",
        str(saved_model_dir),
        str(tfjs_output_dir),
    ]
    print("Running:", " ".join(command))
    result = subprocess.run(command, check=False)
    return result.returncode == 0


def main() -> int:
    config = parse_args()
    set_seed(config.seed)

    output_dir = resolve_path(config.output_dir)
    tfjs_output_dir = resolve_path(config.tfjs_output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    dataset_obj = load_islar_dataset(config)
    dataset = select_dataset_split(dataset_obj, config.dataset_split)
    x, y = build_xy_arrays(dataset, config.img_size, config.max_samples)

    class_names = resolve_class_names(dataset, y)
    num_classes = len(class_names)
    print(f"Total samples: {len(x)}")
    print(f"Detected classes: {num_classes}")

    x_train, y_train, x_val, y_val, x_test, y_test = split_data(
        x,
        y,
        test_size=config.test_size,
        val_size=config.val_size,
        seed=config.seed,
    )

    print(f"Train/Val/Test: {len(x_train)}/{len(x_val)}/{len(x_test)}")

    train_ds = make_tf_dataset(x_train, y_train, config.batch_size, training=True)
    val_ds = make_tf_dataset(x_val, y_val, config.batch_size, training=False)
    test_ds = make_tf_dataset(x_test, y_test, config.batch_size, training=False)

    model = build_model(config.model_name, config.img_size, num_classes)
    train_model(model, train_ds, val_ds, config.learning_rate, config.epochs)

    test_metrics = model.evaluate(test_ds, return_dict=True)
    print("Test metrics:", test_metrics)

    saved_model_dir = output_dir / "saved_model"
    try:
        model.export(str(saved_model_dir))
    except AttributeError:
        model.save(str(saved_model_dir))

    keras_model_path = output_dir / "isl_classifier.keras"
    model.save(keras_model_path)

    with (output_dir / "metrics.json").open("w", encoding="utf-8") as file:
        json.dump(test_metrics, file, indent=2)

    save_label_artifacts(class_names, output_dir)

    if config.export_tflite:
        tflite_path = export_tflite_model(model, output_dir)
        print(f"TFLite exported: {tflite_path}")

    if config.export_tfjs:
        success = export_tfjs_model(saved_model_dir, tfjs_output_dir)
        if success:
            print(f"TFJS model exported to: {tfjs_output_dir}")
        else:
            print("TFJS export failed or was skipped")

    print(f"Training complete. Artifacts at: {output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
