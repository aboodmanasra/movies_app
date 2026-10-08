/// Central home for all TMDB URLs and endpoint paths.
///
/// Keeping these in one place means there are no "magic strings" scattered
/// through the codebase — if TMDB ever changes a path, we fix it once here.
class ApiConstants {
  const ApiConstants._();

  /// Base URL for all TMDB API v3 requests.
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Base URL for images. TMDB only returns a relative path (e.g. "/abc.jpg");
  /// we build the full URL as: imageBaseUrl + size + path.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Common image sizes offered by TMDB.
  static const String posterSizeSmall = '/w185';
  static const String posterSizeMedium = '/w342';
  static const String posterSizeLarge = '/w500';
  static const String posterSizeOriginal = '/original';
  static const String backdropSize = '/w780';
  static const String logoSizeSmall = '/w92';

  // --- Endpoints ---
  static const String searchMovie = '/search/movie';
  static const String discoverMovie = '/discover/movie';
  static const String trending = '/trending/movie/week';
  static const String topRated = '/movie/top_rated';
  static const String nowPlaying = '/movie/now_playing';
  static const String popular = '/movie/popular';
  static const String movieDetails = '/movie'; // + '/{id}'
  static const String watchProviders = '/watch/providers';

  /// Builds a full poster URL from TMDB's relative path.
  /// Returns an empty string when there's no image.
  static String posterUrl(String? path, {String size = posterSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }

  /// Builds a full (wide) backdrop URL. Empty string when there's no image.
  static String backdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$backdropSize$path';
  }

  /// Builds a full streaming-provider logo URL. Empty when there's no logo.
  static String logoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$logoSizeSmall$path';
  }
}
