import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../models/movie.dart';

/// A reusable movie poster card — used by Search, Discover, Watchlist, etc.
///
/// Shows the poster (cached), a rating badge, the title and year. Because it's
/// in `shared/`, every feature renders movies the same way for free.
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = ApiConstants.posterUrl(movie.posterPath);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _poster(context, posterUrl),
                  if (movie.voteAverage > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _RatingBadge(rating: movie.voteAverage),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          if (movie.year.isNotEmpty)
            Text(
              movie.year,
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _poster(BuildContext context, String url) {
    final placeholderColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    if (url.isEmpty) {
      return Container(
        color: placeholderColor,
        child: const Icon(Icons.movie_outlined, size: 40),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: placeholderColor),
      errorWidget: (_, __, ___) => Container(
        color: placeholderColor,
        child: const Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Color(0xFFE0B15E)),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
