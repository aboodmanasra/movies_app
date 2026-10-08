/// A single streaming/rental provider (Netflix, Prime Video, Apple TV…).
class WatchProvider {
  final String name;
  final String? logoPath; // relative TMDB path

  const WatchProvider({required this.name, this.logoPath});

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      name: (json['provider_name'] ?? '') as String,
      logoPath: json['logo_path'] as String?,
    );
  }
}

/// Where a movie can be watched in a given region, split by how you get it.
///   • stream = included with a subscription (TMDB calls this "flatrate")
///   • rent   = pay-per-view rental
///   • buy    = purchase
class WatchProviders {
  final List<WatchProvider> stream;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;
  final String? link; // JustWatch page for this title/region

  const WatchProviders({
    this.stream = const [],
    this.rent = const [],
    this.buy = const [],
    this.link,
  });

  bool get isEmpty => stream.isEmpty && rent.isEmpty && buy.isEmpty;

  /// Parses the object TMDB returns for ONE region (e.g. results["US"]).
  factory WatchProviders.fromRegionJson(Map<String, dynamic> json) {
    List<WatchProvider> parse(String key) {
      final list = (json[key] as List<dynamic>?) ?? [];
      return list
          .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WatchProviders(
      stream: parse('flatrate'),
      rent: parse('rent'),
      buy: parse('buy'),
      link: json['link'] as String?,
    );
  }
}
