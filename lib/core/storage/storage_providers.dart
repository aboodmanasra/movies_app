import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exposes the app's SharedPreferences instance to Riverpod.
///
/// SharedPreferences loads asynchronously, so we resolve it ONCE in `main()`
/// and inject it here via `overrideWithValue`. Every provider downstream then
/// gets it synchronously — no async plumbing scattered through the app.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the resolved '
    'SharedPreferences instance.',
  );
});
