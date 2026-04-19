import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullImagePage({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imagePath,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}
