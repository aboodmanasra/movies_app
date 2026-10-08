import 'cast_member.dart';
import 'video.dart';
import 'watch_providers.dart';

/// The full detail view of a movie, assembled from a single TMDB request that
/// uses `append_to_response=credits,videos,watch/providers` — so one network
/// call gives us details + cast/crew + trailers + streaming availability.
class MovieDetails {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final int runtime; // minutes
  final List<String> genres;
  final List<CastMember> cast;
  final String? director;
  final Video? trailer;
  final WatchProviders providers;

  const MovieDetails({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.releaseDate,
    this.runtime = 0,
    this.genres = const [],
    this.cast = const [],
    this.director,
    this.trailer,
    this.providers = const WatchProviders(),
  });

  /// Release year only (e.g. "2010"). Empty if unknown.
  String get year {
    if (releaseDate == null || releaseDate!.length < 4) return '';
    return releaseDate!.substring(0, 4);
  }

  /// Human-friendly runtime, e.g. "2h 18m". Empty when unknown.
  String get runtimeLabel {
    if (runtime <= 0) return '';
    final h = runtime ~/ 60;
    final m = runtime % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  factory MovieDetails.fromJson(
    Map<String, dynamic> json, {
    String region = 'US',
  }) {
    // Genres → list of names.
    final genres = ((json['genres'] as List<dynamic>?) ?? [])
        .map((g) => ((g as Map<String, dynamic>)['name'] ?? '') as String)
        .where((s) => s.isNotEmpty)
        .toList();

    // Credits → top cast + director.
    final credits = json['credits'] as Map<String, dynamic>?;
    final cast = ((credits?['cast'] as List<dynamic>?) ?? [])
        .take(12)
        .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
        .toList();

    String? director;
    for (final c in (credits?['crew'] as List<dynamic>?) ?? []) {
      final crew = c as Map<String, dynamic>;
      if (crew['job'] == 'Director') {
        director = crew['name'] as String?;
        break;
      }
    }

    // Videos → prefer a YouTube "Trailer", else any YouTube video.
    final videos = ((json['videos'] as Map<String, dynamic>?)?['results']
                as List<dynamic>? ??
            [])
        .map((v) => Video.fromJson(v as Map<String, dynamic>))
        .where((v) => v.site == 'YouTube')
        .toList();
    Video? trailer;
    if (videos.isNotEmpty) {
      trailer = videos.firstWhere(
        (v) => v.type == 'Trailer',
        orElse: () => videos.first,
      );
    }

    // Watch providers for the requested region.
    final regionMap = ((json['watch/providers'] as Map<String, dynamic>?)?[
            'results'] as Map<String, dynamic>?)?[region]
        as Map<String, dynamic>?;
    final providers = regionMap != null
        ? WatchProviders.fromRegionJson(regionMap)
        : const WatchProviders();

    return MovieDetails(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String?,
      runtime: (json['runtime'] as int?) ?? 0,
      genres: genres,
      cast: cast,
      director: director,
      trailer: trailer,
      providers: providers,
    );
  }
}
