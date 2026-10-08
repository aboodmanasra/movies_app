/// A TMDB genre (stable id + display name). Hardcoded because TMDB's genre ids
/// never change, saving us an extra API call to fetch the list.
class Genre {
  final int id;
  final String name;
  const Genre(this.id, this.name);

  static const List<Genre> all = [
    Genre(28, 'Action'),
    Genre(12, 'Adventure'),
    Genre(16, 'Animation'),
    Genre(35, 'Comedy'),
    Genre(80, 'Crime'),
    Genre(99, 'Documentary'),
    Genre(18, 'Drama'),
    Genre(10751, 'Family'),
    Genre(14, 'Fantasy'),
    Genre(36, 'History'),
    Genre(27, 'Horror'),
    Genre(10402, 'Music'),
    Genre(9648, 'Mystery'),
    Genre(10749, 'Romance'),
    Genre(878, 'Sci-Fi'),
    Genre(53, 'Thriller'),
    Genre(10752, 'War'),
    Genre(37, 'Western'),
  ];
}

/// The vibe the user is after. Each mood maps to a few TMDB genre ids.
enum Mood {
  any('Any', '🎬', []),
  chill('Chill', '😌', [35, 10751, 10749]),
  intense('Intense', '😰', [53, 28, 80]),
  feelGood('Feel-good', '😊', [35, 10402, 10749]),
  mindBending('Mind-bending', '🤯', [878, 9648, 53]),
  scary('Scary', '😱', [27, 53]),
  emotional('Emotional', '😢', [18, 10749]);

  const Mood(this.label, this.emoji, this.genreIds);
  final String label;
  final String emoji;
  final List<int> genreIds;
}

/// Who you're watching with — nudges the genre pool when nothing else is set.
enum Company {
  solo('Solo', '🧑', []),
  date('Date', '❤️', [10749]),
  friends('Friends', '🎉', [35, 28]),
  family('Family', '👨‍👩‍👧', [10751, 16]);

  const Company(this.label, this.emoji, this.genreHints);
  final String label;
  final String emoji;
  final List<int> genreHints;
}

/// How much attention you've got right now — shapes sort + length defaults.
enum BrainLevel {
  light('Light', '🍿'),
  heavy('Heavy', '🧠');

  const BrainLevel(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Everything the recommender needs, plus the logic to turn it into a TMDB
/// `/discover/movie` query. Keeping the query-building here (not in the UI)
/// means the "magic" is one readable, testable place.
class RecommendationFilters {
  final Mood mood;
  final Genre? genre; // explicit genre overrides mood/company hints
  final Company company;
  final BrainLevel brain;
  final double minRating; // 0..9
  final int? maxRuntime; // minutes, null = any

  const RecommendationFilters({
    this.mood = Mood.any,
    this.genre,
    this.company = Company.solo,
    this.brain = BrainLevel.light,
    this.minRating = 6,
    this.maxRuntime,
  });

  Map<String, dynamic> toQuery({int page = 1}) {
    // Resolve which genres to ask for.
    final genreIds = <int>{};
    if (genre != null) {
      genreIds.add(genre!.id); // explicit pick wins
    } else {
      genreIds.addAll(mood.genreIds);
      if (mood == Mood.any) genreIds.addAll(company.genreHints);
    }

    final query = <String, dynamic>{
      'include_adult': false,
      // Heavy brain → reward critically-loved films; light → crowd-pleasers.
      'sort_by': brain == BrainLevel.heavy ? 'vote_average.desc' : 'popularity.desc',
      'vote_count.gte': brain == BrainLevel.heavy ? 300 : 150,
      'vote_average.gte': minRating,
      'page': page,
    };

    if (genreIds.isNotEmpty) {
      // '|' = OR (match ANY of these genres) → broader, better results.
      query['with_genres'] = genreIds.join('|');
    }

    // Explicit runtime wins; otherwise a light brain implies "keep it short".
    final runtime = maxRuntime ?? (brain == BrainLevel.light ? 120 : null);
    if (runtime != null) query['with_runtime.lte'] = runtime;

    return query;
  }
}
