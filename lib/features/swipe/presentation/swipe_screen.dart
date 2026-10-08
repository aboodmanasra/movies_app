import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';
import '../../movie_details/presentation/movie_details_screen.dart';
import '../../watchlist/data/models/saved_movie.dart';
import '../../watchlist/presentation/watchlist_providers.dart';
import '../data/swipe_repository.dart';
import 'swipe_providers.dart';

/// Swipe Discovery: a Tinder-style card stack.
///   • swipe right → save to watchlist
///   • swipe left  → skip
/// A theme selector at the top keeps sessions feeling curated, not random.
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();
  SwipeTheme _theme = SwipeTheme.trending;
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTheme(SwipeTheme theme) {
    if (theme == _theme) return;
    setState(() {
      _theme = theme;
      _finished = false;
    });
  }

  void _handleSwipe(Movie movie, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      ref.read(watchlistProvider.notifier).add(SavedMovie.fromMovie(movie));
    }
    // Left = skip: nothing to persist.
  }

  void _restart() {
    ref.invalidate(swipePoolProvider(_theme)); // fetch a fresh pool
    setState(() => _finished = false);
  }

  @override
  Widget build(BuildContext context) {
    final poolAsync = ref.watch(swipePoolProvider(_theme));

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe')),
      body: Column(
        children: [
          _ThemeChips(selected: _theme, onSelect: _selectTheme),
          Expanded(
            child: poolAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Failed to load movies.')),
              data: (movies) {
                if (movies.isEmpty) {
                  return const Center(child: Text('No movies to swipe right now.'));
                }
                if (_finished) {
                  return _FinishedState(onRestart: _restart);
                }
                return _buildSwiper(movies);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiper(List<Movie> movies) {
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            key: ValueKey(_theme), // rebuild the stack when the theme changes
            controller: _controller,
            cardsCount: movies.length,
            isLoop: false,
            numberOfCardsDisplayed: movies.length < 3 ? movies.length : 3,
            allowedSwipeDirection:
                const AllowedSwipeDirection.only(left: true, right: true),
            padding: const EdgeInsets.all(20),
            onSwipe: (previousIndex, currentIndex, direction) {
              _handleSwipe(movies[previousIndex], direction);
              return true;
            },
            onEnd: () => setState(() => _finished = true),
            cardBuilder: (context, index, horizontalOffset, verticalOffset) {
              return _SwipeCard(
                movie: movies[index],
                percentX: horizontalOffset,
                onInfo: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MovieDetailsScreen(movieId: movies[index].id),
                  ),
                ),
              );
            },
          ),
        ),
        _ActionButtons(
          onSkip: () => _controller.swipe(CardSwiperDirection.left),
          onLike: () => _controller.swipe(CardSwiperDirection.right),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ThemeChips extends StatelessWidget {
  final SwipeTheme selected;
  final ValueChanged<SwipeTheme> onSelect;

  const _ThemeChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final theme in SwipeTheme.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(theme.label),
                selected: theme == selected,
                onSelected: (_) => onSelect(theme),
              ),
            ),
        ],
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final Movie movie;
  final int percentX; // -100 (full left) .. 100 (full right)
  final VoidCallback onInfo;

  const _SwipeCard({
    required this.movie,
    required this.percentX,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.posterUrl(movie.posterPath,
        size: ApiConstants.posterSizeLarge);
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    final likeOpacity = (percentX / 100).clamp(0.0, 1.0);
    final nopeOpacity = (-percentX / 100).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            Container(color: bg)
          else
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: bg),
              errorWidget: (_, __, ___) => Container(color: bg),
            ),
          // Bottom gradient for text legibility.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent, Colors.black87],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Title + meta.
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (movie.year.isNotEmpty)
                      Text(movie.year,
                          style: const TextStyle(color: Colors.white70)),
                    if (movie.voteAverage > 0) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.star, size: 15, color: Color(0xFFE0B15E)),
                      const SizedBox(width: 3),
                      Text(movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Info button → full details.
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: onInfo,
            ),
          ),
          // LIKE / NOPE stamps that fade in as you drag.
          Positioned(
            top: 24,
            left: 20,
            child: Opacity(
              opacity: likeOpacity,
              child: _Stamp(text: 'SAVE', color: Colors.greenAccent),
            ),
          ),
          Positioned(
            top: 24,
            right: 20,
            child: Opacity(
              opacity: nopeOpacity,
              child: _Stamp(text: 'SKIP', color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final String text;
  final Color color;
  const _Stamp({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: text == 'SAVE' ? -0.3 : 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onLike;

  const _ActionButtons({required this.onSkip, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.close,
          color: Colors.redAccent,
          onTap: onSkip,
        ),
        const SizedBox(width: 40),
        _CircleButton(
          icon: Icons.favorite,
          color: Colors.greenAccent.shade400,
          onTap: onLike,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }
}

class _FinishedState extends StatelessWidget {
  final VoidCallback onRestart;
  const _FinishedState({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 56),
          const SizedBox(height: 12),
          const Text("That's everyone for now!"),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Fresh batch'),
          ),
        ],
      ),
    );
  }
}
