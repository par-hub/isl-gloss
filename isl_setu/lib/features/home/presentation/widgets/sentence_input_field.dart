import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'mic_button.dart';

class SentenceInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClear;

  const SentenceInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      maxLines: 4,
      minLines: 3,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Type or speak an English or Hindi sentence...',
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const MicButton(),
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
