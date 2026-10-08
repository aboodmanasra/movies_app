import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';
import '../../watchlist/data/models/saved_movie.dart';
import '../../watchlist/presentation/watchlist_providers.dart';
import '../data/models/movie_details.dart';
import 'movie_details_providers.dart';
import 'widgets/streaming_section.dart';

/// Full details for a single movie. Given only a movie id, it fetches
/// everything (details + cast + trailer + streaming) via one provider.
class MovieDetailsScreen extends ConsumerWidget {
  final int movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _ErrorState(),
        data: (details) => _DetailsView(details: details),
      ),
    );
  }
}

class _DetailsView extends ConsumerWidget {
  final MovieDetails details;
  const _DetailsView({required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch just whether THIS movie is saved, to drive the ♥ icon.
    final isSaved =
        ref.watch(watchlistProvider).any((m) => m.id == details.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
              color: isSaved ? const Color(0xFFE0B15E) : null,
              tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
              onPressed: () => _toggleSaved(context, ref, isSaved),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(background: _Backdrop(details: details)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(details: details),
                if (details.genres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Genres(genres: details.genres),
                ],
                if (details.trailer != null) ...[
                  const SizedBox(height: 16),
                  _TrailerButton(url: details.trailer!.youtubeUrl),
                ],
                if ((details.overview ?? '').isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _SectionTitle('Overview'),
                  const SizedBox(height: 8),
                  Text(
                    details.overview!,
                    style: TextStyle(
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
                if (details.cast.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _SectionTitle('Cast'),
                  const SizedBox(height: 12),
                  _CastList(cast: details.cast),
                ],
                const SizedBox(height: 24),
                const _SectionTitle('Where to watch'),
                const SizedBox(height: 12),
                StreamingSection(providers: details.providers),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleSaved(BuildContext context, WidgetRef ref, bool isSaved) {
    final movie = Movie(
      id: details.id,
      title: details.title,
      posterPath: details.posterPath,
      voteAverage: details.voteAverage,
      releaseDate: details.releaseDate,
    );
    ref.read(watchlistProvider.notifier).toggle(SavedMovie.fromMovie(movie));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Removed from watchlist' : 'Added to watchlist'),
          duration: const Duration(seconds: 1),
        ),
      );
  }
}

class _Backdrop extends StatelessWidget {
  final MovieDetails details;
  const _Backdrop({required this.details});

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.backdropUrl(details.backdropPath);
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Stack(
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
        // Gradient so the collapsing app bar / status bar stays readable.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent, Colors.black87],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final MovieDetails details;
  const _Header({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final posterUrl = ApiConstants.posterUrl(details.posterPath);
    final bg = theme.colorScheme.surfaceContainerHighest;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 100,
            height: 150,
            child: posterUrl.isEmpty
                ? Container(color: bg, child: const Icon(Icons.movie_outlined))
                : CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (details.year.isNotEmpty)
                    Text(details.year, style: TextStyle(color: muted)),
                  if (details.runtimeLabel.isNotEmpty)
                    Text(details.runtimeLabel, style: TextStyle(color: muted)),
                  if (details.voteAverage > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 15, color: Color(0xFFE0B15E)),
                        const SizedBox(width: 3),
                        Text(details.voteAverage.toStringAsFixed(1),
                            style: TextStyle(color: muted)),
                      ],
                    ),
                ],
              ),
              if (details.director != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Directed by ${details.director}',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Genres extends StatelessWidget {
  final List<String> genres;
  const _Genres({required this.genres});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres
          .map((g) => Chip(
                label: Text(g, style: const TextStyle(fontSize: 12)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }
}

class _TrailerButton extends StatelessWidget {
  final String url;
  const _TrailerButton({required this.url});

  Future<void> _launch(BuildContext context) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the trailer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _launch(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Watch Trailer'),
      ),
    );
  }
}

class _CastList extends StatelessWidget {
  final List cast;
  const _CastList({required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final member = cast[i];
          final url = ApiConstants.posterUrl(
            member.profilePath,
            size: ApiConstants.posterSizeSmall,
          );
          return SizedBox(
            width: 74,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      url.isEmpty ? null : CachedNetworkImageProvider(url),
                  child: url.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: 6),
                Text(
                  member.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text("Couldn't load this movie."),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
