import 'package:cloud_firestore/cloud_firestore.dart';

class EditHistoryModel {
  final String id;
  final String originalImage;
  final String resultImage;
  final String styleName;
  final String category;
  final DateTime createdAt;
  final DateTime? expiresAt;

  EditHistoryModel({
    required this.id,
    required this.originalImage,
    required this.resultImage,
    required this.styleName,
    required this.category,
    required this.createdAt,
    this.expiresAt,
  });

  factory EditHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EditHistoryModel(
      id: doc.id,
      originalImage: data['original_image'] ?? '',
      resultImage: data['result_image'] ?? '',
      styleName: data['style_name'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      expiresAt: data['expires_at'] != null
          ? (data['expires_at'] as Timestamp).toDate()
          : null,
    );
  }

  // Check if expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Days left
  int get daysLeft {
    if (expiresAt == null) return 999;
    return expiresAt!.difference(DateTime.now()).inDays;
  }
}