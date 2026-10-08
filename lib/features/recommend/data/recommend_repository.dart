import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';
import 'models/recommendation_filters.dart';

/// Turns a set of filters into a TMDB `/discover/movie` query and returns ONE
/// recommendation, picked randomly from the top slice so "Try again" feels
/// fresh instead of always giving the same #1 result.
class RecommendRepository {
  final Dio _dio;
  RecommendRepository(this._dio);

  final _random = Random();

  Future<Movie?> recommend(RecommendationFilters filters) async {
    final response = await _dio.get(
      ApiConstants.discoverMovie,
      queryParameters: filters.toQuery(page: 1 + _random.nextInt(3)),
    );
    return _pickOne(response);
  }

  /// Zero-input random pick from broadly popular movies.
  Future<Movie?> surprise() async {
    final response = await _dio.get(
      ApiConstants.discoverMovie,
      queryParameters: {
        'sort_by': 'popularity.desc',
        'vote_count.gte': 200,
        'include_adult': false,
        'page': 1 + _random.nextInt(5),
      },
    );
    return _pickOne(response);
  }

  Movie? _pickOne(Response response) {
    final results = ((response.data['results'] as List<dynamic>?) ?? [])
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .where((m) => m.posterPath != null && m.posterPath!.isNotEmpty)
        .toList();
    if (results.isEmpty) return null;
    final pool = results.take(12).toList();
    return pool[_random.nextInt(pool.length)];
  }
}
