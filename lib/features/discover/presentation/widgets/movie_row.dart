import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/movie.dart';
import '../../../../shared/widgets/movie_card.dart';
import '../../../movie_details/presentation/movie_details_screen.dart';

/// A titled, horizontally-scrolling row of movies for the Discover screen.
///
/// It takes a *provider* (not a fixed list), so each row watches its own async
/// source and shows its own loading/error state — decoupled from its siblings.
class MovieRow extends ConsumerWidget {
  final String title;
  final FutureProvider<List<Movie>> provider;

  const MovieRow({super.key, required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 210,
          child: moviesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load')),
            data: (movies) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final movie = movies[i];
                return SizedBox(
                  width: 120,
                  child: MovieCard(
                    movie: movie,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(movieId: movie.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
