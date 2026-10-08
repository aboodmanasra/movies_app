import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/movie_card.dart';
import '../../movie_details/presentation/movie_details_screen.dart';
import '../data/models/saved_movie.dart';
import 'watchlist_providers.dart';

/// The Watchlist tab: two lists — "Want to Watch" and "Watched".
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(watchlistProvider);
    final want =
        all.where((m) => m.status == WatchStatus.wantToWatch).toList();
    final watched =
        all.where((m) => m.status == WatchStatus.watched).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Watchlist'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Want to Watch'), Tab(text: 'Watched')],
          ),
        ),
        body: TabBarView(
          children: [
            _WatchGrid(
              movies: want,
              emptyText: 'Nothing saved yet.\nTap ♥ on a movie to add it here.',
            ),
            _WatchGrid(
              movies: watched,
              emptyText: 'Nothing marked as watched yet.',
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchGrid extends ConsumerWidget {
  final List<SavedMovie> movies;
  final String emptyText;

  const _WatchGrid({required this.movies, required this.emptyText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (movies.isEmpty) {
      final muted =
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 48, color: muted),
              const SizedBox(height: 12),
              Text(emptyText, textAlign: TextAlign.center,
                  style: TextStyle(color: muted)),
            ],
          ),
        ),
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
        final saved = movies[i];
        return MovieCard(
          movie: saved.toMovie(),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(movieId: saved.id),
            ),
          ),
          onLongPress: () => _showActions(context, ref, saved),
        );
      },
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, SavedMovie saved) {
    final notifier = ref.read(watchlistProvider.notifier);
    final isWatched = saved.status == WatchStatus.watched;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(saved.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: Icon(isWatched ? Icons.bookmark : Icons.check_circle),
                title: Text(isWatched
                    ? 'Move to Want to Watch'
                    : 'Mark as Watched'),
                onTap: () {
                  notifier.setStatus(
                    saved.id,
                    isWatched
                        ? WatchStatus.wantToWatch
                        : WatchStatus.watched,
                  );
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(saved.note.isEmpty ? 'Add a note' : 'Edit note'),
                subtitle: saved.note.isEmpty ? null : Text(saved.note),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editNote(context, ref, saved);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove from watchlist'),
                onTap: () {
                  notifier.remove(saved.id);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editNote(BuildContext context, WidgetRef ref, SavedMovie saved) {
    final controller = TextEditingController(text: saved.note);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Your note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'e.g. "Sarah said this was amazing"',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(watchlistProvider.notifier)
                    .setNote(saved.id, controller.text.trim());
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
