import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  final File? imageFile;
  final VoidCallback? onEdit;
  final bool isAnalyzing;

  const ImagePreview({
    super.key,
    required this.imageFile,
    this.onEdit,
    this.isAnalyzing = false,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isAnalyzing) {
      _scanController.repeat(reverse: true);
      _rotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnalyzing && !oldWidget.isAnalyzing) {
      _scanController.repeat(reverse: true);
      _rotateController.repeat();
    } else if (!widget.isAnalyzing && oldWidget.isAnalyzing) {
      _scanController.stop();
      _rotateController.stop();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = widget.imageFile != null && widget.imageFile!.existsSync();

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
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.file(
                    widget.imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                else
                  Column(
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

                // AI Loading Overlay
                if (widget.isAnalyzing && hasImage)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotateController,
                            child: const Icon(
                              Icons.camera,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Analyzing with AI...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Scanning Line
                if (widget.isAnalyzing && hasImage)
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanController.value * 280,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                            color: scheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (hasImage && !widget.isAnalyzing)
            Positioned(
              bottom: -20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: _ActionChipButton(
                      label: 'Sửa ảnh (Cắt thủ công)',
                      icon: Icons.crop,
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      onTap: widget.onEdit,
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