import '../../../../shared/models/movie.dart';

/// Whether a saved movie is still on the "to watch" pile or already watched.
enum WatchStatus {
  wantToWatch,
  watched;

  String get storageValue => name;

  static WatchStatus fromStorage(String? value) =>
      value == 'watched' ? WatchStatus.watched : WatchStatus.wantToWatch;
}

/// A movie the user has saved to their watchlist, plus watchlist-specific
/// metadata (status, personal note, when it was saved).
///
/// It stores just the core movie fields it needs to render a card, so the
/// watchlist works fully offline without re-fetching from TMDB.
class SavedMovie {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final WatchStatus status;
  final String note;
  final DateTime savedAt;

  const SavedMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.voteAverage = 0,
    this.releaseDate,
    this.status = WatchStatus.wantToWatch,
    this.note = '',
    required this.savedAt,
  });

  String get year {
    if (releaseDate == null || releaseDate!.length < 4) return '';
    return releaseDate!.substring(0, 4);
  }

  /// Build a savable entry from any Movie (search/discover result).
  factory SavedMovie.fromMovie(
    Movie movie, {
    WatchStatus status = WatchStatus.wantToWatch,
    String note = '',
  }) {
    return SavedMovie(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      status: status,
      note: note,
      savedAt: DateTime.now(),
    );
  }

  /// Convert back to a plain Movie so we can reuse MovieCard for rendering.
  Movie toMovie() => Movie(
        id: id,
        title: title,
        posterPath: posterPath,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
      );

  SavedMovie copyWith({WatchStatus? status, String? note}) {
    return SavedMovie(
      id: id,
      title: title,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      status: status ?? this.status,
      note: note ?? this.note,
      savedAt: savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'vote_average': voteAverage,
        'release_date': releaseDate,
        'status': status.storageValue,
        'note': note,
        'saved_at': savedAt.toIso8601String(),
      };

  factory SavedMovie.fromJson(Map<String, dynamic> json) {
    return SavedMovie(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String?,
      status: WatchStatus.fromStorage(json['status'] as String?),
      note: (json['note'] ?? '') as String,
      savedAt: DateTime.tryParse((json['saved_at'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
