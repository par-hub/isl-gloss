# ISL Gloss — Indian Sign Language Tools

This repository brings together an ISL gloss-generation service and a Flutter companion app exploring speech/text input and avatar-related presentation.

## Repository structure

- [`isl_gloss_server/`](isl_gloss_server/) — Python service for English-to-Indian Sign Language gloss generation using a fine-tuned mT5 model. See its [setup guide](isl_gloss_server/README.md).
- [`isl_setu/`](isl_setu/) — Flutter app with feature-based source folders and avatar assets. See its [app README](isl_setu/README.md).

## Run the gloss server

The server has its own dependency file. From the repository root:

```bash
cd isl_gloss_server
python -m venv .venv
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Use the server's [README](isl_gloss_server/README.md) for endpoint details and testing.

## Run the Flutter app

Open a second terminal:

```bash
cd isl_setu
flutter pub get
flutter run
```

Before expecting a complete end-to-end flow, verify the app's API configuration, model availability, permissions, and avatar/pose integration.

## Technology

Python · FastAPI · Transformers/mT5 · Flutter · Dart · speech_to_text · Dio · WebView · 3D avatar assets

## Scope and limitations

This is an evolving accessibility/translation project. Generated gloss is not a substitute for validation by fluent Indian Sign Language users or interpreters. Test linguistic quality and accessibility with appropriate domain expertise before relying on output.
