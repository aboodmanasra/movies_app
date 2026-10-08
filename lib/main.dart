import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/main_shell.dart';
import 'core/storage/storage_providers.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  // Required before using any plugins (like SharedPreferences) prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve SharedPreferences once, then inject it into the provider graph so
  // the rest of the app can read it synchronously.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MvoiesApp(),
    ),
  );
}

class MvoiesApp extends StatelessWidget {
  const MvoiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mvoiesApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
