import 'dart:io';
import 'package:flutter/material.dart';

class SquircleProfileImage extends StatelessWidget {
  final String imagePath;
  final double size;
  final double radius;

  const SquircleProfileImage({
    super.key,
    required this.imagePath,
    this.size = 120,
    this.radius = 30, // 🔥 controls squircle look
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
        image: imagePath.isEmpty
            ? null
            : DecorationImage(
                image: _getImageProvider(),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: imagePath.isEmpty
          ? const Icon(Icons.person, size: 50, color: Colors.grey)
          : null,
    );
  }

  ImageProvider _getImageProvider() {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    return FileImage(File(imagePath));
  }
}
