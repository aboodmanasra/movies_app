/// User's local app settings (persisted). Kept tiny for V1.
class Settings {
  /// Effective ISO country code (always set) used for region-specific data.
  final String region;

  /// true  = region was auto-detected from the device locale.
  /// false = the user picked an explicit override.
  final bool regionIsAuto;

  /// Optional display name shown on the profile.
  final String displayName;

  /// Local file path to the user's chosen profile picture ('' = none).
  final String profileImagePath;

  const Settings({
    this.region = 'US',
    this.regionIsAuto = true,
    this.displayName = '',
    this.profileImagePath = '',
  });

  Settings copyWith({
    String? region,
    bool? regionIsAuto,
    String? displayName,
    String? profileImagePath,
  }) =>
      Settings(
        region: region ?? this.region,
        regionIsAuto: regionIsAuto ?? this.regionIsAuto,
        displayName: displayName ?? this.displayName,
        profileImagePath: profileImagePath ?? this.profileImagePath,
      );
}

/// The regions available for the hidden override (curated subset of TMDB's).
/// Each entry is (ISO country code, display name).
class Regions {
  const Regions._();

  static const List<(String, String)> all = [
    ('US', 'United States'),
    ('GB', 'United Kingdom'),
    ('CA', 'Canada'),
    ('AU', 'Australia'),
    ('IE', 'Ireland'),
    ('IN', 'India'),
    ('DE', 'Germany'),
    ('FR', 'France'),
    ('ES', 'Spain'),
    ('IT', 'Italy'),
    ('NL', 'Netherlands'),
    ('SE', 'Sweden'),
    ('NO', 'Norway'),
    ('DK', 'Denmark'),
    ('BR', 'Brazil'),
    ('MX', 'Mexico'),
    ('AR', 'Argentina'),
    ('JP', 'Japan'),
    ('KR', 'South Korea'),
    ('AE', 'United Arab Emirates'),
    ('SA', 'Saudi Arabia'),
    ('EG', 'Egypt'),
    ('ZA', 'South Africa'),
  ];

  static String nameFor(String code) {
    for (final r in all) {
      if (r.$1 == code) return r.$2;
    }
    return code;
  }
}
