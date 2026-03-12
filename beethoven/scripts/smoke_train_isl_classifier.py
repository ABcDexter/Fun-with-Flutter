"""
Quick smoke check for train_isl_classifier.py components.

Runs a forward pass and verifies output shape without full training.
"""

from __future__ import annotations

import numpy as np

from train_isl_classifier import build_model


def main() -> int:
    num_classes = 41
    img_size = 224
    batch_size = 2

    model = build_model("mobilenetv3_small", img_size=img_size, num_classes=num_classes)
    x = np.random.rand(batch_size, img_size, img_size, 3).astype(np.float32)
    y = model.predict(x, verbose=0)

    assert y.shape == (batch_size, num_classes), f"Unexpected output shape: {y.shape}"
    print("Smoke check passed:", y.shape)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
