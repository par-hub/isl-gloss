import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/application/settings_controller.dart';
import '../../translation/application/translation_controller.dart';
import '../application/avatar_playback_controller.dart';
import 'widgets/avatar_viewport.dart';
import 'widgets/playback_controls.dart';

class TranslationPlaybackScreen extends ConsumerStatefulWidget {
  const TranslationPlaybackScreen({super.key});

  @override
  ConsumerState<TranslationPlaybackScreen> createState() => _TranslationPlaybackScreenState();
}

class _TranslationPlaybackScreenState extends ConsumerState<TranslationPlaybackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayback();
    });
  }

  void _initPlayback() {
    final translationState = ref.read(translationControllerProvider);
    final defaultSpeed = ref.read(settingsControllerProvider).defaultSpeed;

    translationState.whenData((glossResult) {
      if (glossResult != null && glossResult.stitchResult != null) {
        ref.read(avatarPlaybackControllerProvider.notifier).setFrames(
              glossResult.stitchResult!.frames,
              initialSpeed: defaultSpeed,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationControllerProvider);
    final playbackState = ref.watch(avatarPlaybackControllerProvider);
    final playbackNotifier = ref.read(avatarPlaybackControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Translation'),
      ),
      body: translationState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 48),
                const SizedBox(height: 16),
                Text(
                  err.toString(),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Input'),
                ),
              ],
            ),
          ),
        ),
        data: (glossResult) {
          if (glossResult == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No translation active.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go to Input'),
                  ),
                ],
              ),
            );
          }

          final stitchResult = glossResult.stitchResult;
          final missingWords = stitchResult?.missingWords ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original Sentence Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ORIGINAL SENTENCE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${glossResult.originalSentence}"',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Gloss Tokens Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ISL GLOSS GRAMMAR',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: glossResult.glossTokens.map((token) {
                            final isMissing = missingWords.contains(token.toUpperCase());
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isMissing
                                    ? AppColors.warningOrange.withOpacity(0.15)
                                    : AppColors.primaryTeal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isMissing
                                      ? AppColors.warningOrange.withOpacity(0.5)
                                      : AppColors.primaryTeal.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                token,
                                style: TextStyle(
                                  color: isMissing
                                      ? AppColors.warningOrange
                                      : AppColors.primaryTealLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Non-blocking Missing Word Warning Banner if any missing words
                if (missingWords.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warningOrange.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warningOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Words not in pose dictionary: ${missingWords.join(", ")}. Playing available gestures.',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3D Avatar Viewport
                AvatarViewport(
                  currentFrame: playbackState.currentFrame,
                  isPlaying: playbackState.isPlaying,
                ),
                const SizedBox(height: 16),

                // Playback Controls Bar
                PlaybackControls(
                  currentFrame: playbackState.currentFrameIndex,
                  totalFrames: playbackState.totalFrames,
                  isPlaying: playbackState.isPlaying,
                  speed: playbackState.speed,
                  onTogglePlayPause: () => playbackNotifier.togglePlayPause(),
                  onReplay: () => playbackNotifier.replay(),
                  onSpeedChanged: (speed) => playbackNotifier.setSpeed(speed),
                  onSeek: (frame) => playbackNotifier.seekTo(frame.round()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
