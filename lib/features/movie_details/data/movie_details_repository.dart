import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import 'models/movie_details.dart';

/// Fetches everything the details screen needs in ONE request, using TMDB's
/// `append_to_response` trick to bundle credits, videos and watch providers
/// into the movie payload — fewer round-trips, faster screen.
class MovieDetailsRepository {
  final Dio _dio;
  const MovieDetailsRepository(this._dio);

  Future<MovieDetails> getDetails(int movieId, {String region = 'US'}) async {
    final response = await _dio.get(
      '${ApiConstants.movieDetails}/$movieId',
      queryParameters: {
        'append_to_response': 'credits,videos,watch/providers',
      },
    );

    return MovieDetails.fromJson(
      response.data as Map<String, dynamic>,
      region: region,
    );
  }
}
