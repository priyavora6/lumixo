import 'package:flutter/material.dart';

class AppIcons {
  static const Map<String, IconData> categoryIcons = {
    'business': Icons.business_center,
    'wedding': Icons.favorite,
    'birthday': Icons.cake,
    'festival': Icons.celebration,
    'social_media': Icons.web,
    'traditional_characters': Icons.person,
    'mens_styles': Icons.male,
    'womens_styles': Icons.female,
    'creative': Icons.brush,
  };

  static IconData getCategoryIcon(String categoryId) {
    return categoryIcons[categoryId] ?? Icons.category;
  }
}
