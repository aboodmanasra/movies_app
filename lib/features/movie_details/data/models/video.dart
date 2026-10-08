/// A video associated with a movie (trailer, teaser, clip…).
/// We mostly care about YouTube trailers.
class Video {
  final String key; // YouTube video id
  final String site; // e.g. "YouTube"
  final String type; // e.g. "Trailer", "Teaser"
  final String name;

  const Video({
    required this.key,
    required this.site,
    required this.type,
    required this.name,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      key: (json['key'] ?? '') as String,
      site: (json['site'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      name: (json['name'] ?? '') as String,
    );
  }

  /// The watchable YouTube URL for this video.
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}
