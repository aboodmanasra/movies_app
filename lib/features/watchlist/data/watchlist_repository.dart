import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/saved_movie.dart';

/// Persists the watchlist locally.
///
/// Right now it serializes the whole list to JSON in SharedPreferences — dead
/// simple and perfect for a personal watchlist. Because the rest of the app
/// only talks to THIS class (never to SharedPreferences directly), we can later
/// swap the storage for Hive/Isar/SQLite without touching any UI or provider.
class WatchlistRepository {
  static const _storageKey = 'watchlist_v1';

  final SharedPreferences _prefs;
  const WatchlistRepository(this._prefs);

  List<SavedMovie> getAll() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => SavedMovie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<SavedMovie> movies) async {
    final raw = jsonEncode(movies.map((m) => m.toJson()).toList());
    await _prefs.setString(_storageKey, raw);
  }
}
