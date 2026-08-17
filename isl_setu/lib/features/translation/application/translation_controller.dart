import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../avatar/data/motion_stitcher.dart';
import '../../history/data/history_repository.dart';
import '../data/gloss_repository.dart';
import '../domain/gloss_result.dart';

final translationControllerProvider =
    StateNotifierProvider<TranslationController, AsyncValue<GlossResult?>>((ref) {
  final glossRepo = ref.watch(glossRepositoryProvider);
  final motionStitcher = ref.watch(motionStitcherProvider);
  final historyRepo = ref.watch(historyRepositoryProvider);
  return TranslationController(glossRepo, motionStitcher, historyRepo);
});

class TranslationController extends StateNotifier<AsyncValue<GlossResult?>> {
  final GlossRepository _glossRepository;
  final MotionStitcher _motionStitcher;
  final HistoryRepository _historyRepository;

  TranslationController(
    this._glossRepository,
    this._motionStitcher,
    this._historyRepository,
  ) : super(const AsyncValue.data(null));

  Future<GlossResult?> translateSentence(String sentence) async {
    final cleanSentence = sentence.trim();
    if (cleanSentence.isEmpty) return null;

    state = const AsyncValue.loading();

    try {
      final glossTokens = await _glossRepository.translateTextToGloss(cleanSentence);
      final stitchResult = _motionStitcher.stitch(glossTokens);

      final result = GlossResult(
        originalSentence: cleanSentence,
        glossTokens: glossTokens,
        stitchResult: stitchResult,
        isLoading: false,
      );

      state = AsyncValue.data(result);

      // Save to translation history (Text -> Sign only)
      await _historyRepository.addHistoryItem(cleanSentence);

      return result;
    } catch (e, st) {
      final errorMsg = e is GlossApiException ? e.message : e.toString();
      state = AsyncValue.error(errorMsg, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
