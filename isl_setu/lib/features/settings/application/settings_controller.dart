import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/speech_repository.dart';

class SettingsState {
  final String language; // 'English' or 'Hindi'
  final double defaultSpeed; // 0.5, 1.0, 1.5, 2.0

  const SettingsState({
    this.language = 'English',
    this.defaultSpeed = 1.0,
  });

  SettingsState copyWith({
    String? language,
    double? defaultSpeed,
  }) {
    return SettingsState(
      language: language ?? this.language,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
    );
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void setDefaultSpeed(double speed) {
    state = state.copyWith(defaultSpeed: speed);
  }
}

final isHindiSpeechAvailableProvider = FutureProvider<bool>((ref) async {
  final speechRepo = ref.watch(speechRepositoryProvider);
  final locale = await speechRepo.findLocaleForLanguage('Hindi');
  return locale != null;
});
