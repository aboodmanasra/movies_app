import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/models/settings.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Holds the live user settings and persists every change.
/// Other features (e.g. movie details) read `settingsProvider.region` so the
/// whole app reacts when the region changes.
class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => ref.watch(settingsRepositoryProvider).load();

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> setRegionOverride(String code) async {
    await _repo.setRegionOverride(code);
    state = state.copyWith(region: code, regionIsAuto: false);
  }

  Future<void> useAutoRegion() async {
    await _repo.clearRegionOverride();
    state = state.copyWith(
      region: SettingsRepository.deviceRegion(),
      regionIsAuto: true,
    );
  }

  Future<void> setDisplayName(String name) async {
    await _repo.setDisplayName(name);
    state = state.copyWith(displayName: name);
  }

  Future<void> setProfileImagePath(String path) async {
    await _repo.setProfileImagePath(path);
    state = state.copyWith(profileImagePath: path);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
