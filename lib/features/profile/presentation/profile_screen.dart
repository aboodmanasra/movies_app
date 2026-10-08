import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../watchlist/data/models/saved_movie.dart';
import '../../watchlist/presentation/watchlist_providers.dart';
import '../data/models/settings.dart';
import 'settings_providers.dart';

/// The Profile tab: profile picture, name, watchlist stats, and a small About
/// footer (hidden region override + required TMDB attribution).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final watchlist = ref.watch(watchlistProvider);
    final wantCount =
        watchlist.where((m) => m.status == WatchStatus.wantToWatch).length;
    final watchedCount =
        watchlist.where((m) => m.status == WatchStatus.watched).length;
    final name =
        settings.displayName.isEmpty ? 'Movie Fan' : settings.displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(child: _Avatar(path: settings.profileImagePath, onTap: () => _pickImage(ref))),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => _editName(context, ref, settings.displayName),
              child: const Text('Edit name'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bookmark_border,
                  value: wantCount,
                  label: 'Want to Watch',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  value: watchedCount,
                  label: 'Watched',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _AboutFooter(settings: settings, onTapRegion: () => _pickRegion(context, ref, settings)),
        ],
      ),
    );
  }

  // -------------------------------------------------------- profile picture

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 85,
    );
    if (picked == null) return;

    // Copy into the app's documents dir so it survives after the temp file is
    // gone. A unique filename avoids Flutter's image cache showing a stale pic.
    final dir = await getApplicationDocumentsDirectory();
    final dest =
        '${dir.path}/profile_pic_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy(dest);
    await ref.read(settingsProvider.notifier).setProfileImagePath(saved.path);
  }

  // ---------------------------------------------------------------- name

  void _editName(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setDisplayName(controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- region

  void _pickRegion(BuildContext context, WidgetRef ref, Settings settings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Auto-detect (device)'),
            trailing: settings.regionIsAuto
                ? const Icon(Icons.check, color: Color(0xFFE0B15E))
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).useAutoRegion();
              Navigator.pop(sheetContext);
            },
          ),
          const Divider(height: 0),
          for (final region in Regions.all)
            ListTile(
              leading: Text(region.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              title: Text(region.$2),
              trailing: (!settings.regionIsAuto && region.$1 == settings.region)
                  ? const Icon(Icons.check, color: Color(0xFFE0B15E))
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setRegionOverride(region.$1);
                Navigator.pop(sheetContext);
              },
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String path;
  final VoidCallback onTap;

  const _Avatar({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPic = path.isNotEmpty && File(path).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: hasPic ? FileImage(File(path)) : null,
            child: hasPic ? null : const Icon(Icons.person, size: 48),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0B15E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 26, color: const Color(0xFFE0B15E)),
            const SizedBox(height: 8),
            Text('$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                )),
          ],
        ),
      ),
    );
  }
}

/// Small, low-key footer: a quiet region row + the required TMDB attribution.
class _AboutFooter extends StatelessWidget {
  final Settings settings;
  final VoidCallback onTapRegion;

  const _AboutFooter({required this.settings, required this.onTapRegion});

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final regionLabel = settings.regionIsAuto
        ? 'Auto · ${Regions.nameFor(settings.region)}'
        : Regions.nameFor(settings.region);

    return Column(
      children: [
        InkWell(
          onTap: onTapRegion,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.public, size: 18, color: muted),
                const SizedBox(width: 10),
                Text('Region', style: TextStyle(color: muted)),
                const Spacer(),
                Text(regionLabel, style: TextStyle(color: muted, fontSize: 13)),
                Icon(Icons.chevron_right, size: 18, color: muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'mvoiesApp · v1.0.0',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          'Uses the TMDB API but is not endorsed or certified by TMDB. '
          'Streaming data by JustWatch.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 10.5, height: 1.4),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
