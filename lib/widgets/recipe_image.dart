import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows the recipe photo, or a placeholder icon when there is none.
class RecipeImage extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final double radius;

  const RecipeImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = path != null && path!.isNotEmpty && File(path!).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: hasImage
          ? Image.file(File(path!), width: width, height: height, fit: BoxFit.cover)
          : Container(
              width: width,
              height: height,
              color: AppTheme.softOrange,
              child: const Icon(Icons.restaurant, color: AppTheme.orange, size: 36),
            ),
    );
  }
}
