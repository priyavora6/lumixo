import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int order;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.order,
    required this.isActive,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      imageUrl: data['image_url'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['is_active'] ?? true,
    );
  }
}