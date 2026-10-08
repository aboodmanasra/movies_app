import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/movie_card.dart';
import '../../movie_details/presentation/movie_details_screen.dart';
import 'search_providers.dart';

/// The Search feature's screen: a debounced search field over a results grid.
///
/// It's a ConsumerStatefulWidget because we need local state (the text
/// controller, a debounce timer, and the current query) alongside Riverpod
/// access via `ref`.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  /// The current, debounced query. This is local UI state — no other screen
  /// needs it — so it lives here rather than in a global provider.
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // refresh the clear-button visibility immediately
    // Debounce: wait 400ms after the last keystroke before searching, so
    // typing "batman" makes ONE call, not six.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _query = '');
  }

  void _openDetails(int movieId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movieId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              // autofocus off: this screen lives in an IndexedStack, so
              // autofocus would pop the keyboard even when Search isn't the
              // visible tab.
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Search movies…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return const _CenteredHint(
        icon: Icons.movie_outlined,
        text: 'Search for any movie by title.',
      );
    }

    // Watching the family provider with the current query gives us an
    // AsyncValue we can pattern-match on: loading / error / data.
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const _CenteredHint(
        icon: Icons.error_outline,
        text: 'Something went wrong.\nCheck your connection and try again.',
      ),
      data: (movies) {
        if (movies.isEmpty) {
          return _CenteredHint(
            icon: Icons.search_off,
            text: 'No results for "$_query".',
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: movies.length,
          itemBuilder: (context, i) {
            final movie = movies[i];
            return MovieCard(
              movie: movie,
              onTap: () => _openDetails(movie.id),
            );
          },
        );
      },
    );
  }
}

/// Small helper for the empty / error / no-results states.
class _CenteredHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CenteredHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
