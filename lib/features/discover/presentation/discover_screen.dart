import 'package:flutter/material.dart';

import '../../recommend/presentation/recommend_screen.dart';
import 'discover_providers.dart';
import 'widgets/movie_row.dart';

/// The Discover tab: a vertical scroll of horizontal "browse" rows, led by a
/// banner into the "What Should I Watch?" recommender.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView(
        children: [
          const _RecommendBanner(),
          MovieRow(title: 'Trending This Week', provider: trendingProvider),
          MovieRow(title: 'Popular', provider: popularProvider),
          MovieRow(title: 'Top Rated', provider: topRatedProvider),
          MovieRow(title: 'Now Playing', provider: nowPlayingProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// The entry point into the recommender, pinned at the top of Discover.
class _RecommendBanner extends StatelessWidget {
  const _RecommendBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecommendScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A2F1A), Color(0xFF1A1620)],
            ),
            border: Border.all(color: const Color(0xFFE0B15E), width: 1),
          ),
          child: Row(
            children: [
              const Text('🎲', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What should I watch?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tell us your vibe — we'll pick.",
                      style: TextStyle(fontSize: 12.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
