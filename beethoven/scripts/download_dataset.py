"""
ISLAR Dataset Downloader
Downloads the ISLAR dataset from Hugging Face and saves it locally for training.
"""

import argparse
import sys
from pathlib import Path

from datasets import load_dataset


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download the ISLAR dataset and save it locally."
    )
    parser.add_argument(
        "--dataset",
        default="akshaybahadur21/ISLAR",
        help="Hugging Face dataset name (default: akshaybahadur21/ISLAR)",
    )
    parser.add_argument(
        "--output_dir",
        default="../assets/data/islar",
        help="Directory to save the dataset (relative to scripts/ if not absolute)",
    )
    parser.add_argument(
        "--cache_dir",
        default=None,
        help="Optional Hugging Face cache directory",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing output directory if it has contents",
    )
    return parser.parse_args()


def resolve_output_dir(output_dir: str) -> Path:
    path = Path(output_dir).expanduser()
    if path.is_absolute():
        return path
    script_dir = Path(__file__).resolve().parent
    return (script_dir / path).resolve()


def main() -> int:
    args = parse_args()
    output_dir = resolve_output_dir(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    if any(output_dir.iterdir()) and not args.force:
        print(
            f"Output directory already has files: {output_dir}\n"
            "Use --force to overwrite."
        )
        return 1

    print(f"Downloading dataset: {args.dataset}")
    dataset = load_dataset(args.dataset, cache_dir=args.cache_dir)

    print(f"Saving dataset to: {output_dir}")
    dataset.save_to_disk(str(output_dir))

    print("Download complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
