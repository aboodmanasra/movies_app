import 'package:flutter/material.dart';

/// Central theme configuration for the whole app.
///
/// Movie apps look best dark — posters and artwork pop against a dark ground —
/// so we ship a dark-first Material 3 theme. Reskin the entire app by changing
/// the single `_seed` colour below.
class AppTheme {
  const AppTheme._();

  /// Brand accent. Change this one value to re-theme the app.
  static const Color _seed = Color(0xFFE0B15E); // warm cinematic gold

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0E0E12),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // More component themes (cards, chips, inputs) will be added here as
      // the UI grows, so styling stays consistent everywhere.
    );
  }
}
