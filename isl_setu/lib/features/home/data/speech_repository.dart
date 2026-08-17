import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechRepositoryProvider = Provider<SpeechRepository>((ref) {
  return SpeechRepository();
});

class SpeechRepository {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _speechToText.isAvailable;

  /// Check and request microphone and speech recognition permissions using permission_handler
  Future<PermissionStatus> checkAndRequestPermission() async {
    print('DEBUG: checking mic permission status...');
    final micStatus = await Permission.microphone.status;
    print('DEBUG: mic permission status is: $micStatus');
    
    PermissionStatus finalMicStatus = micStatus;
    if (micStatus.isDenied) {
      print('DEBUG: requesting mic permission...');
      finalMicStatus = await Permission.microphone.request();
      print('DEBUG: mic permission request result: $finalMicStatus');
    }

    print('DEBUG: checking speech recognition permission status...');
    final speechStatus = await Permission.speech.status;
    print('DEBUG: speech recognition permission status is: $speechStatus');

    PermissionStatus finalSpeechStatus = speechStatus;
    if (speechStatus.isDenied) {
      print('DEBUG: requesting speech recognition permission...');
      finalSpeechStatus = await Permission.speech.request();
      print('DEBUG: speech recognition permission request result: $finalSpeechStatus');
    }

    // Return the overall combined status
    if (finalMicStatus.isGranted && finalSpeechStatus.isGranted) {
      return PermissionStatus.granted;
    } else if (finalMicStatus.isPermanentlyDenied || finalSpeechStatus.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    } else if (finalMicStatus.isRestricted || finalSpeechStatus.isRestricted) {
      return PermissionStatus.restricted;
    } else {
      return PermissionStatus.denied;
    }
  }

  /// Initialize SpeechToText engine if not already initialized
  Future<bool> initialize({
    Function(String error)? onError,
    Function(String status)? onStatus,
  }) async {
    if (_isInitialized && _speechToText.isAvailable) {
      print('DEBUG: speech already initialized and available');
      return true;
    }
    try {
      print('DEBUG: calling SpeechToText.initialize()...');
      _isInitialized = await _speechToText.initialize(
        onError: (errorNotification) {
          print('DEBUG: SpeechToText onError callback: ${errorNotification.errorMsg}');
          onError?.call(errorNotification.errorMsg);
        },
        onStatus: (status) {
          print('DEBUG: SpeechToText onStatus callback: $status');
          onStatus?.call(status);
        },
      );
      print('DEBUG: SpeechToText.initialize() returned: $_isInitialized');
    } catch (e) {
      print('DEBUG: SpeechToText.initialize() threw: $e');
      _isInitialized = false;
      onError?.call('Speech recognition initialization failed: $e');
    }
    return _isInitialized;
  }

  /// Fetch all supported locales available on this device
  Future<List<LocaleName>> getAvailableLocales() async {
    final available = await initialize();
    if (!available) return [];
    try {
      return await _speechToText.locales();
    } catch (_) {
      return [];
    }
  }

  /// Find matching localeId for language name/code ('English' or 'Hindi')
  Future<LocaleName?> findLocaleForLanguage(String language) async {
    final locales = await getAvailableLocales();
    if (locales.isEmpty) return null;

    final langLower = language.toLowerCase();
    if (langLower == 'hindi') {
      for (final loc in locales) {
        final id = loc.localeId.toLowerCase();
        final name = loc.name.toLowerCase();
        if (id.startsWith('hi') || name.contains('hindi')) {
          return loc;
        }
      }
      return null;
    } else {
      for (final loc in locales) {
        final id = loc.localeId.toLowerCase();
        if (id.startsWith('en')) {
          return loc;
        }
      }
      return locales.firstOrNull;
    }
  }

  /// Start listening with specified localeId, returning stream callbacks
  Future<bool> startListening({
    required String localeId,
    required Function(String recognizedText, bool isFinal) onResult,
    required Function(String errorMsg) onError,
    required Function() onDone,
  }) async {
    print('DEBUG: SpeechRepository.startListening() called with localeId: $localeId');
    final available = await initialize(
      onError: (err) {
        print('DEBUG: SpeechRepository initialize error: $err');
        onError(err);
      },
      onStatus: (status) {
        print('DEBUG: SpeechRepository initialize status: $status');
        if (status == 'done' || status == 'notListening') {
          onDone();
        }
      },
    );

    if (!available) {
      print('DEBUG: SpeechRepository.startListening() - Speech recognition not available, aborting.');
      onError('Speech recognition is not available on this device.');
      return false;
    }

    try {
      print('DEBUG: calling SpeechToText.listen()...');
      await _speechToText.listen(
        onResult: (result) {
          print('DEBUG: SpeechToText.listen() result: ${result.recognizedWords}, final: ${result.finalResult}');
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
      print('DEBUG: SpeechToText.listen() call finished. isListening: ${_speechToText.isListening}');
      return _speechToText.isListening;
    } catch (e) {
      print('DEBUG: SpeechToText.listen() threw: $e');
      onError('Could not start listening: $e');
      return false;
    }
  }

  /// Stop active listening session
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Cancel listening session
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}
