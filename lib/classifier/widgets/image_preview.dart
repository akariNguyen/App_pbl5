import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback? onEdit;

  const ImagePreview({
    super.key,
    required this.imageFile,
    this.onEdit,
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
            height: 280, // giữ đúng kích thước to như cũ
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(24),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.crop,
                          size: 20,
                          color: scheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sửa ảnh',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}