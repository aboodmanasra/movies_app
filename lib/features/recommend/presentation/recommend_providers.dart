import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../shared/models/movie.dart';
import '../data/models/recommendation_filters.dart';
import '../data/recommend_repository.dart';

/// Provides the recommender repository, wired with the shared Dio client.
final recommendRepositoryProvider = Provider<RecommendRepository>((ref) {
  return RecommendRepository(ref.watch(dioProvider));
});

/// Holds the current recommendation result as an AsyncValue.
///
/// It's an action-driven controller (not a plain FutureProvider) because we
/// want a NEW pick every time the user taps "Find" / "Try again" / "Surprise",
/// even with identical filters — a family provider would just return its cache.
class RecommendationController extends AsyncNotifier<Movie?> {
  @override
  FutureOr<Movie?> build() => null; // nothing recommended yet

  Future<void> find(RecommendationFilters filters) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(recommendRepositoryProvider).recommend(filters),
    );
  }

  Future<void> surprise() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(recommendRepositoryProvider).surprise(),
    );
  }
}

final recommendationControllerProvider =
    AsyncNotifierProvider<RecommendationController, Movie?>(
        RecommendationController.new);
