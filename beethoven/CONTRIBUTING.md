# Contributing to Beethoven

Thanks for your interest in contributing! This guide explains how to propose changes, run checks, and submit a PR.

## Getting Started

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Open a pull request

## Development Setup

Follow the setup in `SETUP_GUIDE.md` to install Flutter and Python dependencies.

## Recommended Workflow

```bash
# From the repo root
cd beethoven
flutter pub get
flutter analyze
flutter test
```

## Code Style

- Format Dart code with `dart format lib/ test/`
- Keep changes scoped and focused
- Avoid unrelated refactors

## Commit Messages

Use concise, descriptive messages. Examples:
- `feat : add camera overlay`
- `fix : handle null model path`
- `docs : update setup steps`

## Pull Requests

Include in your PR description:
- What you changed
- Why you changed it
- How you tested

## Reporting Issues

When opening an issue, include:
- Steps to reproduce
- Expected vs actual behavior
- Device/OS info
- Logs or screenshots if relevant

## License

By contributing, you agree your work will be licensed under the project’s license.
