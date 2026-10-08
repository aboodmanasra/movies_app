/// Template for `api_config.dart` (which is git-ignored so real keys never
/// land in version control).
///
/// To run the project on a fresh clone:
///   1. Copy this file to `api_config.dart` in the same folder.
///   2. Replace the placeholder below with your own TMDB API key.
class ApiConfig {
  const ApiConfig._();

  /// TMDB API key (v3 auth).
  /// Get one free at https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
}
