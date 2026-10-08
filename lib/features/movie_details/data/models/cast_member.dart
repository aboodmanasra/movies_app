/// One person in a movie's cast.
class CastMember {
  final String name;
  final String? character;
  final String? profilePath; // relative TMDB path, may be null

  const CastMember({
    required this.name,
    this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: (json['name'] ?? '') as String,
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }
}
