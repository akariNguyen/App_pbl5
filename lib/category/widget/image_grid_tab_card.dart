import 'package:flutter/material.dart';
import 'full_image_page.dart';

class ImageGridTab extends StatelessWidget {
  final List<String> images;

  const ImageGridTab({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(
        child: Text('Không có ảnh'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imagePath = images[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullImagePage(
                  imagePath: imagePath,
                  title: 'Ảnh ${index + 1}/${images.length}',
                ),
              ),
            );
          },
          child: Hero(
            tag: imagePath,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}