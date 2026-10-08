import 'package:flutter/material.dart';

import '../features/discover/presentation/discover_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/swipe/presentation/swipe_screen.dart';
import '../features/watchlist/presentation/watchlist_screen.dart';

/// The app's root navigation shell: a bottom nav bar over the main tabs.
///
/// Uses an IndexedStack so each tab keeps its state (scroll position, search
/// text) when you switch away and back — instead of rebuilding from scratch.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // All tabs are const, so they're built once and cheaply kept alive.
  static const List<Widget> _tabs = [
    DiscoverScreen(),
    SearchScreen(),
    SwipeScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Discover',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.swipe_outlined),
            selectedIcon: Icon(Icons.swipe),
            label: 'Swipe',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
