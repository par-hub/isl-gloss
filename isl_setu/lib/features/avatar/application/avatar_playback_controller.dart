import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/motion_frame.dart';

class AvatarPlaybackState {
  final int currentFrameIndex;
  final int totalFrames;
  final bool isPlaying;
  final double speed;
  final List<MotionFrame> frames;

  const AvatarPlaybackState({
    this.currentFrameIndex = 0,
    this.totalFrames = 0,
    this.isPlaying = false,
    this.speed = 1.0,
    this.frames = const [],
  });

  AvatarPlaybackState copyWith({
    int? currentFrameIndex,
    int? totalFrames,
    bool? isPlaying,
    double? speed,
    List<MotionFrame>? frames,
  }) {
    return AvatarPlaybackState(
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      totalFrames: totalFrames ?? this.totalFrames,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      frames: frames ?? this.frames,
    );
  }

  MotionFrame? get currentFrame {
    if (frames.isEmpty || currentFrameIndex >= frames.length) return null;
    return frames[currentFrameIndex];
  }
}

final avatarPlaybackControllerProvider =
    StateNotifierProvider<AvatarPlaybackController, AvatarPlaybackState>((ref) {
  return AvatarPlaybackController();
});

class AvatarPlaybackController extends StateNotifier<AvatarPlaybackState> {
  Timer? _timer;

  AvatarPlaybackController() : super(const AvatarPlaybackState());

  void setFrames(List<MotionFrame> newFrames, {double initialSpeed = 1.0}) {
    _timer?.cancel();
    state = AvatarPlaybackState(
      currentFrameIndex: 0,
      totalFrames: newFrames.length,
      isPlaying: newFrames.isNotEmpty,
      speed: initialSpeed,
      frames: newFrames,
    );

    if (newFrames.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (state.totalFrames == 0) return;

    final intervalMs = (1000 / (30 * state.speed)).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!state.isPlaying) return;

      if (state.currentFrameIndex + 1 < state.totalFrames) {
        state = state.copyWith(currentFrameIndex: state.currentFrameIndex + 1);
      } else {
        // End of animation -> pause
        state = state.copyWith(isPlaying: false);
        _timer?.cancel();
      }
    });
  }

  void play() {
    if (state.totalFrames == 0) return;
    if (state.currentFrameIndex >= state.totalFrames - 1) {
      state = state.copyWith(currentFrameIndex: 0);
    }
    state = state.copyWith(isPlaying: true);
    _startTimer();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void replay() {
    _timer?.cancel();
    state = state.copyWith(currentFrameIndex: 0, isPlaying: true);
    _startTimer();
  }

  void seekTo(int frameIndex) {
    final clamped = frameIndex.clamp(0, state.totalFrames > 0 ? state.totalFrames - 1 : 0);
    state = state.copyWith(currentFrameIndex: clamped);
  }

  void setSpeed(double newSpeed) {
    state = state.copyWith(speed: newSpeed);
    if (state.isPlaying) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
