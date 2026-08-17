import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../settings/application/settings_controller.dart';
import '../data/speech_repository.dart';

enum SpeechListeningState { idle, listening, processing }

class HomeInputState {
  final String text;
  final SpeechListeningState speechState;
  final String? speechError;

  const HomeInputState({
    this.text = '',
    this.speechState = SpeechListeningState.idle,
    this.speechError,
  });

  HomeInputState copyWith({
    String? text,
    SpeechListeningState? speechState,
    String? speechError,
    bool clearError = false,
  }) {
    return HomeInputState(
      text: text ?? this.text,
      speechState: speechState ?? this.speechState,
      speechError: clearError ? null : (speechError ?? this.speechError),
    );
  }
}

final homeInputProvider =
    StateNotifierProvider<HomeInputController, HomeInputState>((ref) {
  return HomeInputController(ref);
});

class HomeInputController extends StateNotifier<HomeInputState> {
  final Ref _ref;

  HomeInputController(this._ref) : super(const HomeInputState());

  void updateText(String val) {
    state = state.copyWith(text: val, clearError: true);
  }

  void clear() {
    state = state.copyWith(text: '', clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> toggleListening({
    required Function() onPermissionDenied,
  }) async {
    if (state.speechState == SpeechListeningState.listening) {
      await stopListening();
    } else if (state.speechState == SpeechListeningState.idle) {
      await startListening(onPermissionDenied: onPermissionDenied);
    }
  }

  Future<void> startListening({
    required Function() onPermissionDenied,
  }) async {
    print('DEBUG: HomeInputController.startListening() called');
    final speechRepo = _ref.read(speechRepositoryProvider);
    final settings = _ref.read(settingsControllerProvider);

    // 1. Check and request mic permission via permission_handler
    print('DEBUG: HomeInputController - calling checkAndRequestPermission');
    final status = await speechRepo.checkAndRequestPermission();
    print('DEBUG: HomeInputController - checkAndRequestPermission returned: $status');
    if (status.isPermanentlyDenied || status.isDenied || status.isRestricted) {
      print('DEBUG: HomeInputController - permission is denied/restricted. Triggering callback.');
      onPermissionDenied();
      return;
    }

    // 2. Check locale support on this device
    final locale = await speechRepo.findLocaleForLanguage(settings.language);
    if (locale == null && settings.language.toLowerCase() == 'hindi') {
      state = state.copyWith(
        speechState: SpeechListeningState.idle,
        speechError:
            'Hindi speech recognition is not available on this device. Defaulting to manual input.',
      );
      return;
    }

    final localeId = locale?.localeId ?? 'en_US';

    // 3. Set listening state
    state = state.copyWith(
      speechState: SpeechListeningState.listening,
      clearError: true,
    );

    // 4. Begin speech recognition stream
    final started = await speechRepo.startListening(
      localeId: localeId,
      onResult: (recognizedText, isFinal) {
        if (recognizedText.isNotEmpty) {
          state = state.copyWith(
            text: recognizedText,
            speechState:
                isFinal ? SpeechListeningState.idle : SpeechListeningState.listening,
          );
        } else if (isFinal) {
          state = state.copyWith(speechState: SpeechListeningState.idle);
        }
      },
      onError: (errorMsg) {
        state = state.copyWith(
          speechState: SpeechListeningState.idle,
          speechError: errorMsg.contains('error_no_match')
              ? 'No speech detected. Please try speaking again.'
              : errorMsg,
        );
      },
      onDone: () {
        if (state.speechState == SpeechListeningState.listening) {
          state = state.copyWith(speechState: SpeechListeningState.idle);
        }
      },
    );

    if (!started && state.speechState == SpeechListeningState.listening) {
      state = state.copyWith(speechState: SpeechListeningState.idle);
    }
  }

  Future<void> stopListening() async {
    state = state.copyWith(speechState: SpeechListeningState.processing);
    final speechRepo = _ref.read(speechRepositoryProvider);
    await speechRepo.stopListening();
    state = state.copyWith(speechState: SpeechListeningState.idle);
  }
}

final quickPhrasesProvider = Provider<List<String>>((ref) {
  return [
    'Good morning',
    'Thank you',
    'Where is the library?',
    'I am going to school today',
    'How are you?',
    'What is your name?',
  ];
});
