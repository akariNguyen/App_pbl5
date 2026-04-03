import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback? onEdit;
  final VoidCallback? onDetect;

  const ImagePreview({
    super.key,
    required this.imageFile,
    this.onEdit,
    this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageFile != null && imageFile!.existsSync();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            clipBehavior: Clip.hardEdge,
            child: hasImage
                ? Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_florist_outlined,
                        size: 64,
                        color: scheme.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có ảnh',
                        style: TextStyle(
                          color: scheme.outline,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),

          if (hasImage)
            Positioned(
              bottom: -20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: _ActionChipButton(
                      label: 'Sửa ảnh',
                      icon: Icons.crop,
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionChipButton(
                      label: 'Detect',
                      icon: Icons.center_focus_strong,
                      backgroundColor: scheme.secondary,
                      foregroundColor: scheme.onSecondary,
                      onTap: onDetect,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _ActionChipButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isEnabled
                ? backgroundColor
                : backgroundColor.withOpacity(0.45),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}