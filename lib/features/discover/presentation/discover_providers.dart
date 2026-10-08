import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../shared/models/movie.dart';
import '../data/discover_repository.dart';

/// Provides the Discover repository, wired with the shared Dio client.
final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepository(ref.watch(dioProvider));
});

// One provider per browse category. Each is a self-contained async source the
// Discover rows can watch independently — so a slow "Top Rated" never blocks
// "Trending" from showing.
final trendingProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(discoverRepositoryProvider).fetchTrending();
});

final popularProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(discoverRepositoryProvider).fetchPopular();
});

final topRatedProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(discoverRepositoryProvider).fetchTopRated();
});

final nowPlayingProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(discoverRepositoryProvider).fetchNowPlaying();
});
