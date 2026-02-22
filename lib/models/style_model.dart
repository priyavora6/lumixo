import 'package:cloud_firestore/cloud_firestore.dart';

class StyleModel {
  final String id;
  final String name;
  final String prompt;
  final String imageUrl;
  final bool isPremium;
  final int order;
  final String? categoryId; // Add this

  StyleModel({
    required this.id,
    required this.name,
    required this.prompt,
    required this.imageUrl,
    required this.isPremium,
    required this.order,
    this.categoryId, // Add this
  });

  factory StyleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StyleModel(
      id: doc.id,
      name: data['name'] ?? '',
      prompt: data['prompt'] ?? '',
      imageUrl: data['image_url'] ?? '',
      isPremium: data['is_premium'] ?? false,
      order: data['order'] ?? 0,
      categoryId: data['category_id'],
    );
  }

  StyleModel copyWith({
    String? id,
    String? name,
    String? prompt,
    String? imageUrl,
    bool? isPremium,
    int? order,
    String? categoryId,
  }) {
    return StyleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      order: order ?? this.order,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
