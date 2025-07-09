import 'package:flutter/material.dart';

class S3Image extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const S3Image({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Text(
          '이미지 없음',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  }
}
