# ISLAR Training Pipeline (`train_isl_classifier.py`)

This training pipeline is designed to avoid label/preprocessing mismatch issues.

## What it does

- Loads ISLAR from Hugging Face or local disk
- Detects class names from dataset metadata (defaults to 41 classes for ISLAR)
- Trains an image classifier (MobileNetV3Small or EfficientNetB0)
- Uses runtime-compatible preprocessing: `224x224`, RGB, float32 `[0,1]`
- Saves:
  - `saved_model/`
  - `isl_classifier.keras`
  - `metrics.json`
  - `label_map.json`
- Optional exports:
  - `isl_classifier.tflite`
  - TFJS model via `tensorflowjs_converter`

## Install

```bash
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
pip install -r requirements.txt
```

## Smoke check (fast)

```bash
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
python smoke_train_isl_classifier.py
```

## Train (recommended first run)

```bash
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
python train_isl_classifier.py \
  --dataset_name akshaybahadur21/ISLAR \
  --dataset_split train \
  --model_name mobilenetv3_small \
  --img_size 224 \
  --batch_size 32 \
  --epochs 12 \
  --output_dir ../saved_model_islar
```

## Train from local dataset

```bash
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
python train_isl_classifier.py \
  --local_dataset_dir ../assets/data/islar \
  --dataset_split train \
  --output_dir ../saved_model_islar
```

## Export TFLite + TFJS

```bash
cd /Users/anubhavbalodhi/learn/Udemy/Flutter-projects/beethoven/scripts
python train_isl_classifier.py \
  --local_dataset_dir ../assets/data/islar \
  --export_tflite \
  --export_tfjs \
  --output_dir ../saved_model_islar \
  --tfjs_output_dir ../web/models/isl_tfjs
```

## Output label mapping

`label_map.json` structure:

- `num_classes`
- `id_to_label`
- `label_to_id`

Use `id_to_label` in Flutter so displayed class names always match training order.
