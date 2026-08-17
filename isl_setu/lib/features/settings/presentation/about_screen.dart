import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ISL Setu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryTeal, width: 2),
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      color: AppColors.primaryTeal,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ISL Setu',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bridging the gap banner section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.diversity_3_rounded,
                          color: AppColors.primaryTeal,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bridging the Gap',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ISL Setu is a state-of-the-art Text-to-Indian-Sign-Language translation system designed to remove communication barriers for millions of Deaf and hard-of-hearing individuals across India.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'By translating natural English & Hindi sentences into standardized ISL glosses and rendering realistic 3D avatar animations in real time, ISL Setu makes digital communication inclusive and accessible for everyone.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Key features list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key Innovations',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem(
                      icon: Icons.psychology_rounded,
                      title: 'Deep Learning Grammar Translation',
                      description: 'Uses custom sequence models trained to translate spoken language grammar into natural ISL gloss structure.',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.view_in_ar_rounded,
                      title: 'Real-time 3D Avatar Rendering',
                      description: 'Stitches 3D landmark trajectories to animate an avatar with fluid hand gestures and body poses.',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.offline_bolt_rounded,
                      title: 'Local Vocabulary Trajectory Lookup',
                      description: 'Keyframe pose dictionary provides keyframe lookup for instant translation playback.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: Text(
                '© 2026 ISL Setu Team • Powered by Deep Learning & Flutter',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryTealLight, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
