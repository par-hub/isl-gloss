import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PlaybackControls extends StatelessWidget {
  final int currentFrame;
  final int totalFrames;
  final bool isPlaying;
  final double speed;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReplay;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSeek;

  const PlaybackControls({
    super.key,
    required this.currentFrame,
    required this.totalFrames,
    required this.isPlaying,
    required this.speed,
    required this.onTogglePlayPause,
    required this.onReplay,
    required this.onSpeedChanged,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalFrames > 0 ? (currentFrame / totalFrames).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Progress Slider & Frame Counter
            Row(
              children: [
                Text(
                  '$currentFrame',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primaryTeal,
                      inactiveTrackColor: AppColors.borderDark,
                      thumbColor: AppColors.primaryTealLight,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: currentFrame.toDouble().clamp(0.0, totalFrames > 0 ? (totalFrames - 1).toDouble() : 0.0),
                      min: 0,
                      max: totalFrames > 0 ? (totalFrames - 1).toDouble() : 0,
                      onChanged: (val) => onSeek(val),
                    ),
                  ),
                ),
                Text(
                  '${totalFrames > 0 ? totalFrames - 1 : 0}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Controls Bar: Speed Selector | Play/Pause & Replay Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed Selector Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: speed,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryTeal),
                      dropdownColor: AppColors.cardDark,
                      style: const TextStyle(
                        color: AppColors.primaryTealLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onChanged: (val) {
                        if (val != null) onSpeedChanged(val);
                      },
                      items: const [
                        DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                        DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                        DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                        DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                      ],
                    ),
                  ),
                ),

                // Main Play/Pause Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_rounded, color: AppColors.textPrimary, size: 28),
                      tooltip: 'Replay Animation',
                      onPressed: onReplay,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 32,
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: onTogglePlayPause,
                      ),
                    ),
                  ],
                ),

                // Frame Progress percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
