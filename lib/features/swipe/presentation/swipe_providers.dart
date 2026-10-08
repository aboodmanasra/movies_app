import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../shared/models/movie.dart';
import '../data/swipe_repository.dart';

/// Provides the swipe repository, wired with the shared Dio client.
final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepository(ref.watch(dioProvider));
});

/// The pool of movies to swipe, for a given theme. `.family` caches per theme
/// so switching back and forth doesn't refetch needlessly.
final swipePoolProvider =
    FutureProvider.autoDispose.family<List<Movie>, SwipeTheme>((ref, theme) {
  return ref.watch(swipeRepositoryProvider).fetchPool(theme);
});
