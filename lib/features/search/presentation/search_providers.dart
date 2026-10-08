import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../shared/models/movie.dart';
import '../data/search_repository.dart';

/// Provides the SearchRepository, wired with the shared Dio client.
/// It reads `dioProvider`, so it automatically gets the key-injecting client.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(dioProvider));
});

/// Fetches results for a given query string.
///   • `.family`      → one cached result per distinct query.
///   • `.autoDispose` → the cache is dropped when no screen is listening,
///                      so we don't hold every past search in memory.
/// The returned AsyncValue gives us loading / error / data states for free.
///
/// Note: the query itself is local UI state owned by SearchScreen, so it
/// isn't a provider — the screen simply passes it in here.
final searchResultsProvider =
    FutureProvider.autoDispose.family<List<Movie>, String>((ref, query) {
  return ref.watch(searchRepositoryProvider).searchMovies(query);
});
