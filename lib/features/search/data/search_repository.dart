import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';

/// Talks to TMDB's search endpoint and turns raw JSON into Movie objects.
///
/// The UI never touches Dio or JSON directly — it always goes through a
/// repository like this one. That boundary is what keeps screens simple and
/// makes the data layer easy to test or swap later.
class SearchRepository {
  final Dio _dio;
  const SearchRepository(this._dio);

  /// Searches movies by [query]. Returns an empty list for a blank query.
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _dio.get(
      ApiConstants.searchMovie,
      queryParameters: {
        'query': query,
        'include_adult': false,
      },
    );

    final results = (response.data['results'] as List<dynamic>?) ?? [];
    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
