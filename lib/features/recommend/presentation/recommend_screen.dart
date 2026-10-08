import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../shared/models/movie.dart';
import '../../movie_details/presentation/movie_details_screen.dart';
import '../../watchlist/data/models/saved_movie.dart';
import '../../watchlist/presentation/watchlist_providers.dart';
import '../data/models/recommendation_filters.dart';
import 'recommend_providers.dart';

/// "What Should I Watch?" — a short vibe form that returns one recommendation,
/// plus a zero-input "Surprise me" button.
class RecommendScreen extends ConsumerStatefulWidget {
  const RecommendScreen({super.key});

  @override
  ConsumerState<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends ConsumerState<RecommendScreen> {
  Mood _mood = Mood.any;
  Genre? _genre;
  Company _company = Company.solo;
  BrainLevel _brain = BrainLevel.light;
  double _minRating = 6;
  int? _maxRuntime;

  bool _showResult = false;
  RecommendationFilters? _lastFilters;

  void _find() {
    final filters = RecommendationFilters(
      mood: _mood,
      genre: _genre,
      company: _company,
      brain: _brain,
      minRating: _minRating,
      maxRuntime: _maxRuntime,
    );
    _lastFilters = filters;
    setState(() => _showResult = true);
    ref.read(recommendationControllerProvider.notifier).find(filters);
  }

  void _surprise() {
    _lastFilters = null;
    setState(() => _showResult = true);
    ref.read(recommendationControllerProvider.notifier).surprise();
  }

  void _tryAgain() {
    final notifier = ref.read(recommendationControllerProvider.notifier);
    _lastFilters != null ? notifier.find(_lastFilters!) : notifier.surprise();
  }

  void _backToForm() {
    setState(() => _showResult = false);
    ref.invalidate(recommendationControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What to Watch')),
      body: _showResult ? _buildResult() : _buildForm(),
    );
  }

  // ---------------------------------------------------------------- form

  Widget _buildForm() {
    final outline = Theme.of(context).colorScheme.outline;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section("I'm in the mood for"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in Mood.values)
              ChoiceChip(
                label: Text('${m.emoji} ${m.label}'),
                selected: _mood == m,
                onSelected: (_) => setState(() => _mood = m),
              ),
          ],
        ),
        const SizedBox(height: 22),
        _section('Genre (optional)'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<Genre?>(
            value: _genre,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text('Any'),
            items: [
              const DropdownMenuItem<Genre?>(value: null, child: Text('Any')),
              for (final g in Genre.all)
                DropdownMenuItem<Genre?>(value: g, child: Text(g.name)),
            ],
            onChanged: (g) => setState(() => _genre = g),
          ),
        ),
        const SizedBox(height: 22),
        _section('Watching with'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in Company.values)
              ChoiceChip(
                label: Text('${c.emoji} ${c.label}'),
                selected: _company == c,
                onSelected: (_) => setState(() => _company = c),
              ),
          ],
        ),
        const SizedBox(height: 22),
        _section('Brain power'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in BrainLevel.values)
              ChoiceChip(
                label: Text('${b.emoji} ${b.label}'),
                selected: _brain == b,
                onSelected: (_) => setState(() => _brain = b),
              ),
          ],
        ),
        const SizedBox(height: 22),
        _section('Minimum rating: ${_minRating.toStringAsFixed(1)}'),
        Slider(
          value: _minRating,
          min: 0,
          max: 9,
          divisions: 18,
          label: _minRating.toStringAsFixed(1),
          onChanged: (v) => setState(() => _minRating = v),
        ),
        const SizedBox(height: 12),
        _section('Max length'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in const [
              (null, 'Any'),
              (90, '< 1½h'),
              (120, '< 2h'),
              (150, '< 2½h'),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: _maxRuntime == option.$1,
                onSelected: (_) => setState(() => _maxRuntime = option.$1),
              ),
          ],
        ),
        const SizedBox(height: 30),
        FilledButton.icon(
          onPressed: _find,
          icon: const Icon(Icons.movie_filter),
          label: const Text('Find my movie'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _surprise,
          icon: const Text('🎲', style: TextStyle(fontSize: 18)),
          label: const Text('Surprise me'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // -------------------------------------------------------------- result

  Widget _buildResult() {
    final async = ref.watch(recommendationControllerProvider);

    return async.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding your movie…'),
          ],
        ),
      ),
      error: (_, __) => _messageState(
        icon: Icons.error_outline,
        text: 'Something went wrong.',
        showTryAgain: true,
      ),
      data: (movie) => movie == null
          ? _messageState(
              icon: Icons.search_off,
              text: 'No match found.\nTry loosening your filters.',
              showTryAgain: false,
            )
          : _resultCard(movie),
    );
  }

  Widget _resultCard(Movie movie) {
    final saved = ref.watch(watchlistProvider).any((m) => m.id == movie.id);
    final url = ApiConstants.posterUrl(movie.posterPath,
        size: ApiConstants.posterSizeLarge);
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: url.isEmpty
                ? Container(color: bg)
                : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Text(movie.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            if (movie.year.isNotEmpty)
              Text(movie.year, style: TextStyle(color: muted)),
            if (movie.voteAverage > 0) ...[
              const SizedBox(width: 10),
              const Icon(Icons.star, size: 15, color: Color(0xFFE0B15E)),
              const SizedBox(width: 3),
              Text(movie.voteAverage.toStringAsFixed(1),
                  style: TextStyle(color: muted)),
            ],
          ],
        ),
        if ((movie.overview ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(movie.overview!, style: TextStyle(height: 1.5, color: muted)),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MovieDetailsScreen(movieId: movie.id),
                  ),
                ),
                icon: const Icon(Icons.info_outline),
                label: const Text('Details'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleSave(movie, saved),
                icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
                label: Text(saved ? 'Saved' : 'Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _tryAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: _backToForm,
                icon: const Icon(Icons.tune),
                label: const Text('Change filters'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleSave(Movie movie, bool saved) {
    ref.read(watchlistProvider.notifier).toggle(SavedMovie.fromMovie(movie));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(saved ? 'Removed from watchlist' : 'Added to watchlist'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Widget _messageState({
    required IconData icon,
    required String text,
    required bool showTryAgain,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (showTryAgain)
            FilledButton(onPressed: _tryAgain, child: const Text('Try again')),
          TextButton(onPressed: _backToForm, child: const Text('Change filters')),
        ],
      ),
    );
  }
}
