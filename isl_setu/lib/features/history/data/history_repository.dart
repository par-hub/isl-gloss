import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/history_item.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

class HistoryRepository {
  static const String _storageKey = 'isl_translation_history';

  Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_storageKey);
      if (rawList == null) return [];

      return rawList
          .map((itemStr) => HistoryItem.decode(itemStr))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error reading translation history: $e');
      return [];
    }
  }

  Future<void> addHistoryItem(String sentence) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getHistory();

      // Avoid duplicating the immediate top item if identical sentence
      if (items.isNotEmpty && items.first.sentence.trim().toLowerCase() == sentence.trim().toLowerCase()) {
        return;
      }

      final newItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sentence: sentence,
        timestamp: DateTime.now(),
      );

      items.insert(0, newItem);

      // Keep max 50 items
      final trimmed = items.take(50).toList();
      final encodedList = trimmed.map((item) => item.encode()).toList();

      await prefs.setStringList(_storageKey, encodedList);
    } catch (e) {
      print('Error saving translation history item: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing translation history: $e');
    }
  }
}
