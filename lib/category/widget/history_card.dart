import 'dart:io';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onTap;
  final bool showDivider;

  const HistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imagePath,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoryThumb(imagePath: imagePath),
                const SizedBox(width: 14),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Divider giống hình
            if (showDivider) ...[
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: scheme.outlineVariant.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryThumb extends StatelessWidget {
  final String? imagePath;

  const _HistoryThumb({this.imagePath});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: 64, height: 64, child: _buildImage(scheme)),
    );
  }

  Widget _buildImage(ColorScheme scheme) {
    if (imagePath == null) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image, color: scheme.outline),
      );
    }

    /// nếu là ảnh local (history)
    if (imagePath!.startsWith('/')) {
      return Image.file(File(imagePath!), fit: BoxFit.cover);
    }

    /// nếu là ảnh server
    return Image.network(
      imagePath!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.broken_image, color: scheme.outline),
      ),
    );
  }
}
