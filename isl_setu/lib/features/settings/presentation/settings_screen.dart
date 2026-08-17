import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../avatar/data/pose_lookup_repository.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final poseRepository = ref.watch(poseLookupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Language Settings
            const Text(
              'Input Language',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language Mode',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'English',
                          label: Text('English'),
                          icon: Icon(Icons.language_rounded, size: 18),
                        ),
                        ButtonSegment<String>(
                          value: 'Hindi',
                          label: Text('Hindi'),
                          icon: Icon(Icons.translate_rounded, size: 18),
                        ),
                      ],
                      selected: {settingsState.language},
                      onSelectionChanged: (Set<String> newSelection) {
                        final selected = newSelection.first;
                        if (selected == 'Hindi') {
                          ref.read(isHindiSpeechAvailableProvider.future).then((available) {
                            if (!available && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Note: Hindi speech recognition locale (hi_IN) is not installed on this device.',
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          });
                        }
                        settingsNotifier.setLanguage(selected);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.primaryTeal.withOpacity(0.25),
                        selectedForegroundColor: AppColors.primaryTealLight,
                        side: const BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ref.watch(isHindiSpeechAvailableProvider).when(
                          data: (isAvailable) => isAvailable
                              ? const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        color: AppColors.primaryTeal, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Speech recognition supported for English & Hindi',
                                      style: TextStyle(
                                          color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                )
                              : const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: AppColors.warningOrange, size: 14),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Hindi speech recognition locale not installed on device engine',
                                        style: TextStyle(
                                            color: AppColors.warningOrange, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Animation Settings
            const Text(
              'Avatar Playback Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Default Playback Speed',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${settingsState.defaultSpeed.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              color: AppColors.primaryTealLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: settingsState.defaultSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      activeColor: AppColors.primaryTeal,
                      inactiveColor: AppColors.borderDark,
                      label: '${settingsState.defaultSpeed.toStringAsFixed(1)}x',
                      onChanged: (val) {
                        settingsNotifier.setDefaultSpeed(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Dynamic Vocabulary Coverage
            const Text(
              'System Vocabulary',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primaryTeal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vocabulary Coverage',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            poseRepository.isLoaded
                                ? '${poseRepository.totalWordCount} ISL Gloss Words Loaded'
                                : 'Loading pose dictionary...',
                            style: const TextStyle(
                              color: AppColors.primaryTealLight,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: App Info & About Link
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal),
                title: const Text(
                  'About ISL Setu',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Mission, architecture & technology overview',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                onTap: () {
                  context.push('/about');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
