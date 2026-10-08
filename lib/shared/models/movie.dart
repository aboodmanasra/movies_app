/// A single movie, as the app understands it — built from TMDB's JSON.
///
/// This is intentionally a small, immutable value object holding only the
/// fields the UI needs. It lives in `shared/` because many features (Search,
/// Discover, Watchlist) all deal in Movies, so they share one definition.
class Movie {
  final int id;
  final String title;
  final String? posterPath; // relative path from TMDB (e.g. "/abc.jpg")
  final String? overview;
  final double voteAverage;
  final String? releaseDate; // "YYYY-MM-DD"

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    this.voteAverage = 0,
    this.releaseDate,
  });

  /// Builds a Movie from one TMDB result object. Defensive about missing
  /// fields, because TMDB frequently omits posters, dates, etc.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String?,
    );
  }

  /// Just the year, for compact display (e.g. "2019"). Empty if unknown.
  String get year {
    if (releaseDate == null || releaseDate!.length < 4) return '';
    return releaseDate!.substring(0, 4);
  }
}
