import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../profile/presentation/settings_providers.dart';
import '../data/models/movie_details.dart';
import '../data/movie_details_repository.dart';

/// Provides the details repository, wired with the shared Dio client.
final movieDetailsRepositoryProvider = Provider<MovieDetailsRepository>((ref) {
  return MovieDetailsRepository(ref.watch(dioProvider));
});

/// Fetches full details for a given movie id, using the user's chosen region
/// so streaming availability matches where they actually live.
/// `.family` keys the cache by id; `.autoDispose` frees it when you leave.
final movieDetailsProvider =
    FutureProvider.autoDispose.family<MovieDetails, int>((ref, movieId) {
  final region = ref.watch(settingsProvider).region;
  return ref
      .watch(movieDetailsRepositoryProvider)
      .getDetails(movieId, region: region);
});
