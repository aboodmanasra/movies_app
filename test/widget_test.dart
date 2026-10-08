// Basic smoke test: confirms the app boots into the navigation shell.
// Network providers and SharedPreferences are stubbed so the test does no I/O.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first_app/main.dart';
import 'package:first_app/core/storage/storage_providers.dart';
import 'package:first_app/features/discover/presentation/discover_providers.dart';

void main() {
  testWidgets('App boots into the nav shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          trendingProvider.overrideWith((ref) async => []),
          popularProvider.overrideWith((ref) async => []),
          topRatedProvider.overrideWith((ref) async => []),
          nowPlayingProvider.overrideWith((ref) async => []),
        ],
        child: const MvoiesApp(),
      ),
    );
    await tester.pump(); // let the overridden futures resolve

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Watchlist'), findsWidgets);
  });
}
