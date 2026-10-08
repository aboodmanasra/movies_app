import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/models/saved_movie.dart';
import '../data/watchlist_repository.dart';

/// Provides the watchlist repository, wired with SharedPreferences.
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(ref.watch(sharedPreferencesProvider));
});

/// Holds the live watchlist in memory and keeps storage in sync.
///
/// Every mutation updates `state` (so the UI rebuilds instantly) AND writes
/// through to the repository (so it survives an app restart). This is the
/// modern Riverpod 3 `Notifier` — not a legacy StateNotifier.
class WatchlistNotifier extends Notifier<List<SavedMovie>> {
  @override
  List<SavedMovie> build() {
    // Initial state is whatever was persisted last session.
    return ref.watch(watchlistRepositoryProvider).getAll();
  }

  WatchlistRepository get _repo => ref.read(watchlistRepositoryProvider);

  bool contains(int movieId) => state.any((m) => m.id == movieId);

  SavedMovie? find(int movieId) {
    for (final m in state) {
      if (m.id == movieId) return m;
    }
    return null;
  }

  Future<void> add(SavedMovie movie) async {
    if (contains(movie.id)) return;
    state = [movie, ...state];
    await _repo.saveAll(state);
  }

  Future<void> remove(int movieId) async {
    state = state.where((m) => m.id != movieId).toList();
    await _repo.saveAll(state);
  }

  /// Add if missing, remove if already saved. Used by the ♥ toggle.
  Future<void> toggle(SavedMovie movie) async {
    if (contains(movie.id)) {
      await remove(movie.id);
    } else {
      await add(movie);
    }
  }

  Future<void> setStatus(int movieId, WatchStatus status) async {
    state = [
      for (final m in state)
        if (m.id == movieId) m.copyWith(status: status) else m,
    ];
    await _repo.saveAll(state);
  }

  Future<void> setNote(int movieId, String note) async {
    state = [
      for (final m in state)
        if (m.id == movieId) m.copyWith(note: note) else m,
    ];
    await _repo.saveAll(state);
  }
}

final watchlistProvider =
    NotifierProvider<WatchlistNotifier, List<SavedMovie>>(WatchlistNotifier.new);
