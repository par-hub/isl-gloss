import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/history_repository.dart';
import '../domain/history_item.dart';

final historyControllerProvider =
    StateNotifierProvider<HistoryController, AsyncValue<List<HistoryItem>>>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryController(repository);
});

class HistoryController extends StateNotifier<AsyncValue<List<HistoryItem>>> {
  final HistoryRepository _repository;

  HistoryController(this._repository) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getHistory();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = const AsyncValue.data([]);
  }
}
