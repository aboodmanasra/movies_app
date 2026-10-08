import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../data/models/watch_providers.dart';

/// Renders "Where to watch": provider logos grouped into Stream / Rent / Buy.
/// TMDB sources this from JustWatch, so we credit them (a licensing courtesy).
class StreamingSection extends StatelessWidget {
  final WatchProviders providers;
  const StreamingSection({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    if (providers.isEmpty) {
      return Text(
        'Not available on streaming in your region yet.',
        style: TextStyle(color: muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (providers.stream.isNotEmpty)
          _ProviderRow(label: 'Stream', providers: providers.stream),
        if (providers.rent.isNotEmpty)
          _ProviderRow(label: 'Rent', providers: providers.rent),
        if (providers.buy.isNotEmpty)
          _ProviderRow(label: 'Buy', providers: providers.buy),
        const SizedBox(height: 4),
        Text(
          'Streaming data by JustWatch',
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final String label;
  final List<WatchProvider> providers;
  const _ProviderRow({required this.label, required this.providers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers.map((p) => _ProviderLogo(provider: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final WatchProvider provider;
  const _ProviderLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.logoUrl(provider.logoPath);
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Tooltip(
      message: provider.name,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 46,
          height: 46,
          child: url.isEmpty
              ? Container(color: placeholder, child: const Icon(Icons.tv, size: 20))
              : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
