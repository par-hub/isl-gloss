import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/permission_denied_dialog.dart';
import '../../application/home_controller.dart';

class MicButton extends ConsumerStatefulWidget {
  const MicButton({super.key});

  @override
  ConsumerState<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends ConsumerState<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeInputProvider);
    final isListening = homeState.speechState == SpeechListeningState.listening;
    final isProcessing = homeState.speechState == SpeechListeningState.processing;

    if (isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Tooltip(
      message: isListening
          ? 'Listening... Tap to stop'
          : isProcessing
              ? 'Processing speech...'
              : 'Voice Input',
      child: GestureDetector(
        onTap: () {
          print('DEBUG: MicButton tapped');
          ref.read(homeInputProvider.notifier).toggleListening(
            onPermissionDenied: () {
              print('DEBUG: MicButton permission denied callback triggered');
              PermissionDeniedDialog.show(context);
            },
          );
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isListening ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppColors.errorRed.withOpacity(0.25)
                      : isProcessing
                          ? AppColors.warningOrange.withOpacity(0.2)
                          : AppColors.primaryTeal.withOpacity(0.12),
                  boxShadow: isListening
                      ? [
                          BoxShadow(
                            color: AppColors.errorRed.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.warningOrange,
                        ),
                      )
                    : Icon(
                        isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: isListening
                            ? AppColors.errorRed
                            : AppColors.primaryTeal,
                        size: 22,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
