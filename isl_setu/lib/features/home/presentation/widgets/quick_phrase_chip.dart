import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuickPhraseChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickPhraseChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.add_rounded, size: 16, color: AppColors.primaryTealLight),
      backgroundColor: AppColors.cardDark,
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppColors.borderDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
