import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/motion_frame.dart';

final poseLookupRepositoryProvider = Provider<PoseLookupRepository>((ref) {
  return PoseLookupRepository();
});

class PoseLookupRepository {
  final Map<String, List<MotionFrame>> _poseMap = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  int get totalWordCount => _poseMap.length;

  Future<void> loadPoseData() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/pose_lookup.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      decoded.forEach((key, value) {
        if (value is List) {
          final frames = value
              .map((frameJson) => MotionFrame.fromJson(frameJson as Map<String, dynamic>))
              .toList();
          _poseMap[key.toUpperCase()] = frames;
        }
      });

      _isLoaded = true;
    } catch (e) {
      print('Error loading pose_lookup.json: $e');
    }
  }

  List<MotionFrame>? getFramesForWord(String word) {
    return _poseMap[word.trim().toUpperCase()];
  }

  bool containsWord(String word) {
    return _poseMap.containsKey(word.trim().toUpperCase());
  }

  List<String> get availableWords => _poseMap.keys.toList();
}
