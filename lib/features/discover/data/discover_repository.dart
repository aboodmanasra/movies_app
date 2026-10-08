import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';

/// Fetches the various "browse" lists for the Discover tab.
///
/// All four endpoints return the same shape (`{ results: [...] }`), so we share
/// one private helper and expose a friendly method per category.
class DiscoverRepository {
  final Dio _dio;
  const DiscoverRepository(this._dio);

  Future<List<Movie>> _getList(String path) async {
    final response = await _dio.get(path);
    final results = (response.data['results'] as List<dynamic>?) ?? [];
    return results
        .map((json) => Movie.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> fetchTrending() => _getList(ApiConstants.trending);
  Future<List<Movie>> fetchPopular() => _getList(ApiConstants.popular);
  Future<List<Movie>> fetchTopRated() => _getList(ApiConstants.topRated);
  Future<List<Movie>> fetchNowPlaying() => _getList(ApiConstants.nowPlaying);
}
