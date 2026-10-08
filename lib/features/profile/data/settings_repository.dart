import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

import 'models/settings.dart';

/// Persists user settings in SharedPreferences (behind this repo, like the
/// watchlist — the UI never touches storage directly).
///
/// Region is auto-detected from the device locale unless the user sets an
/// explicit override (stored under [_regionKey]).
class SettingsRepository {
  static const _regionKey = 'settings_region_override';
  static const _nameKey = 'settings_display_name';
  static const _picKey = 'settings_profile_pic';

  final SharedPreferences _prefs;
  const SettingsRepository(this._prefs);

  /// The device's country code (e.g. "GB"), or "US" if unknown.
  static String deviceRegion() {
    final code = ui.PlatformDispatcher.instance.locale.countryCode;
    return (code != null && code.isNotEmpty) ? code.toUpperCase() : 'US';
  }

  Settings load() {
    final override = _prefs.getString(_regionKey);
    final isAuto = override == null || override.isEmpty;
    return Settings(
      region: isAuto ? deviceRegion() : override,
      regionIsAuto: isAuto,
      displayName: _prefs.getString(_nameKey) ?? '',
      profileImagePath: _prefs.getString(_picKey) ?? '',
    );
  }

  Future<void> setRegionOverride(String code) =>
      _prefs.setString(_regionKey, code);
  Future<void> clearRegionOverride() => _prefs.remove(_regionKey);
  Future<void> setDisplayName(String name) => _prefs.setString(_nameKey, name);
  Future<void> setProfileImagePath(String path) =>
      _prefs.setString(_picKey, path);
}
