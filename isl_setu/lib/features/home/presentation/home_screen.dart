import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../translation/application/translation_controller.dart';
import '../application/home_controller.dart';
import 'widgets/quick_phrase_chip.dart';
import 'widgets/sentence_input_field.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: ref.read(homeInputProvider).text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sentence to translate.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await ref
        .read(translationControllerProvider.notifier)
        .translateSentence(text);

    if (result != null && mounted) {
      context.push('/playback');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in homeInputProvider state to update controller and errors
    ref.listen<HomeInputState>(homeInputProvider, (previous, next) {
      if (next.text != _textController.text) {
        _textController.text = next.text;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        setState(() {});
      }
    });

    final homeState = ref.watch(homeInputProvider);
    final translationState = ref.watch(translationControllerProvider);
    final quickPhrases = ref.watch(quickPhrasesProvider);
    final isLoading = translationState.isLoading;
    final isListening = homeState.speechState == SpeechListeningState.listening;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sign_language_rounded, color: AppColors.primaryTeal),
            SizedBox(width: 8),
            Text('ISL Avatar App'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text to Sign Language',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter or speak a sentence to generate ISL gloss grammar and watch the 3D avatar sign it.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Speech Error Banner
            if (homeState.speechError != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ErrorBanner(
                  message: homeState.speechError!,
                  onRetry: () {
                    ref.read(homeInputProvider.notifier).clearError();
                  },
                ),
              ),
            ],

            // Translation Error Banner
            translationState.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (err, _) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ErrorBanner(
                  message: err.toString(),
                  onRetry: _handleTranslate,
                ),
              ),
            ),

            // Active Listening Banner
            if (isListening)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.errorRed.withOpacity(0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.graphic_eq_rounded,
                        color: AppColors.errorRed, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Listening... Speak clearly into your device microphone.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Input Field
            SentenceInputField(
              controller: _textController,
              onChanged: (val) {
                ref.read(homeInputProvider.notifier).updateText(val);
                setState(() {});
              },
              onSubmitted: _handleTranslate,
              onClear: () {
                _textController.clear();
                ref.read(homeInputProvider.notifier).clear();
                setState(() {});
              },
            ),
            const SizedBox(height: 20),

            // Translate Action Button
            PrimaryButton(
              label: 'Translate to Sign',
              icon: Icons.play_arrow_rounded,
              isLoading: isLoading,
              onPressed:
                  _textController.text.trim().isEmpty ? null : _handleTranslate,
            ),
            const SizedBox(height: 32),

            // Quick Phrase Chips Header
            const Text(
              'Quick Phrases',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickPhrases.map((phrase) {
                return QuickPhraseChip(
                  label: phrase,
                  onTap: () {
                    _textController.text = phrase;
                    ref.read(homeInputProvider.notifier).updateText(phrase);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
