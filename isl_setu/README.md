# ISL Setu — Flutter Companion App

ISL Setu is the Flutter application within the ISL Gloss repository. Its dependencies and assets indicate an app exploring speech input, navigation/state management, web content integration, and 3D avatar assets.

## App components

- `lib/main.dart` and `lib/app.dart` — application entry and app configuration.
- `lib/features/`, `lib/core/`, `lib/shared/` — feature code, shared utilities, and common UI.
- `assets/Avatar2.glb` — 3D avatar asset.
- `assets/pose_lookup.json` — pose lookup data.
- `assets/avatar.html` — web-based avatar resource.

## Run locally

Requirements: Flutter SDK matching the Dart constraint in `pubspec.yaml`, plus Android Studio/Xcode for your target platform.

```bash
flutter pub get
flutter run
```

## Dependencies and integrations

Flutter · Dart · Riverpod · GoRouter · Dio · speech_to_text · WebView · three_dart/flutter_gl

Review runtime permissions, API URLs, model/server availability, and the avatar asset pipeline before treating the app as a complete end-to-end sign-language translation system.

## Parent repository

The sibling `isl_gloss_server/` directory contains the gloss-generation server. See the root README for how the two parts are organized.
