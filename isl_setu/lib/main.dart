import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/avatar/application/avatar_model_provider.dart';
import 'features/avatar/data/pose_lookup_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Preload pose dictionary in background on startup
  try {
    await container.read(poseLookupRepositoryProvider).loadPoseData();
  } catch (e) {
    print('Error preloading pose lookup dictionary: $e');
  }

  // Preload avatar model in background on startup (no-await so it doesn't block UI start)
  container.read(avatarModelBase64Provider.future).catchError((e) {
    print('Error preloading avatar model: $e');
    return '';
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const IslAvatarApp(),
    ),
  );
}
