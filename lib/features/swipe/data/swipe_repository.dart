import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';

/// The themes a swipe session can pull from. Each maps to a TMDB browse
/// endpoint, so switching theme just changes which pool of movies you swipe.
enum SwipeTheme {
  trending('Trending', ApiConstants.trending),
  popular('Popular', ApiConstants.popular),
  topRated('Top Rated', ApiConstants.topRated),
  nowPlaying('New', ApiConstants.nowPlaying);

  const SwipeTheme(this.label, this.path);

  final String label;
  final String path;
}

/// Fetches a pool of movies to swipe through for a given theme.
class SwipeRepository {
  final Dio _dio;
  const SwipeRepository(this._dio);

  Future<List<Movie>> fetchPool(SwipeTheme theme) async {
    final response = await _dio.get(theme.path);
    final results = (response.data['results'] as List<dynamic>?) ?? [];
    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        // Cards without a poster look broken, so we skip them.
        .where((m) => m.posterPath != null && m.posterPath!.isNotEmpty)
        .toList();
  }
}
