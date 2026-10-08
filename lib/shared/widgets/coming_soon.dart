import 'package:flutter/material.dart';

/// A friendly placeholder for tabs/features not built yet.
class ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoon({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: muted),
            const SizedBox(height: 12),
            Text('$title — coming soon', style: TextStyle(color: muted)),
          ],
        ),
      ),
    );
  }
}
