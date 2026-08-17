import '../../avatar/data/motion_stitcher.dart';

class GlossResult {
  final String originalSentence;
  final List<String> glossTokens;
  final StitchResult? stitchResult;
  final bool isLoading;
  final String? error;

  const GlossResult({
    required this.originalSentence,
    required this.glossTokens,
    this.stitchResult,
    this.isLoading = false,
    this.error,
  });

  GlossResult copyWith({
    String? originalSentence,
    List<String>? glossTokens,
    StitchResult? stitchResult,
    bool? isLoading,
    String? error,
  }) {
    return GlossResult(
      originalSentence: originalSentence ?? this.originalSentence,
      glossTokens: glossTokens ?? this.glossTokens,
      stitchResult: stitchResult ?? this.stitchResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
