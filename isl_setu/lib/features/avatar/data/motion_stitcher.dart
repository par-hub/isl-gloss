import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/motion_frame.dart';
import 'pose_lookup_repository.dart';

final motionStitcherProvider = Provider<MotionStitcher>((ref) {
  final repository = ref.watch(poseLookupRepositoryProvider);
  return MotionStitcher(repository);
});

class StitchResult {
  final List<String> usedWords;
  final List<String> missingWords;
  final List<MotionFrame> frames;

  StitchResult({
    required this.usedWords,
    required this.missingWords,
    required this.frames,
  });
}

class MotionStitcher {
  final PoseLookupRepository poseLookupRepository;

  MotionStitcher(this.poseLookupRepository);

  StitchResult stitch(List<String> glossTokens) {
    final List<String> cleanedTokens = [];

    // Step 1: Strip markers like [NEG], [Q], [PAST], [FUT], [WH-Q:...] and FS: prefixes
    for (final rawToken in glossTokens) {
      String token = rawToken.trim();
      if (token.isEmpty) continue;

      // Ignore bracketed markers like [NEG], [Q], etc.
      if (token.startsWith('[') && token.endsWith(']')) {
        continue;
      }

      // Remove FS: finger-spelling prefix
      if (token.toUpperCase().startsWith('FS:')) {
        token = token.substring(3).trim();
      }

      if (token.isNotEmpty) {
        cleanedTokens.add(token.toUpperCase());
      }
    }

    // Step 2: Special combined-phrase handling (e.g. "THANK" + "YOU" -> "THANK YOU")
    final List<String> phraseTokens = [];
    int i = 0;
    while (i < cleanedTokens.length) {
      if (i < cleanedTokens.length - 1) {
        final combined = '${cleanedTokens[i]} ${cleanedTokens[i + 1]}';
        if (poseLookupRepository.containsWord(combined)) {
          phraseTokens.add(combined);
          i += 2;
          continue;
        }
      }
      phraseTokens.add(cleanedTokens[i]);
      i++;
    }

    // Step 3: Lookup each token in repository, concatenate frames & record missing words
    final List<String> usedWords = [];
    final List<String> missingWords = [];
    final List<MotionFrame> concatenatedFrames = [];

    for (final token in phraseTokens) {
      final frames = poseLookupRepository.getFramesForWord(token);
      if (frames != null && frames.isNotEmpty) {
        usedWords.add(token);
        concatenatedFrames.addAll(frames);
      } else {
        missingWords.add(token);
      }
    }

    return StitchResult(
      usedWords: usedWords,
      missingWords: missingWords,
      frames: concatenatedFrames,
    );
  }
}
