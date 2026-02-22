import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel {
  final String id;
  final String title;
  final String prompt;
  final String category;
  final List<String> tags;
  final bool isTrending;
  final bool isPremium;
  final int order;

  // ════════════════════════════════════════════════
  // ✅ NEWLY ADDED — fixes all prompt_detail errors
  // ════════════════════════════════════════════════

  // AppColors.negativePrompt → line 41, 42, 176, 179
  final String negativePrompt;

  // prompt.previewImageUrl → line 79, 81
  final String previewImageUrl;

  // prompt.likesCount → line 154
  final int likesCount;

  // prompt.copiesCount → line 156
  final int copiesCount;

  // prompt.aiModel → line 158
  final String aiModel;

  // prompt.aspectRatio → line 160
  final String aspectRatio;

  // prompt.style → used in settings row
  final String style;

  // prompt.categoryName → used in settings row
  final String categoryName;

  const PromptModel({
    required this.id,
    required this.title,
    required this.prompt,
    required this.category,
    required this.tags,
    this.isTrending = false,
    this.isPremium = false,
    this.order = 0,
    // New fields with defaults so nothing breaks
    this.negativePrompt = '',
    this.previewImageUrl = '',
    this.likesCount = 0,
    this.copiesCount = 0,
    this.aiModel = 'Stable Diffusion',
    this.aspectRatio = '1:1',
    this.style = '',
    this.categoryName = '',
  });

  // ─── FROM FIRESTORE ───────────────────────────────
  factory PromptModel.fromFirestore(
      DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromptModel(
      id: doc.id,
      title: data['title'] ?? '',
      prompt: data['prompt'] ?? '',
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isTrending: data['is_trending'] ?? false,
      isPremium: data['is_premium'] ?? false,
      order: data['order'] ?? 0,
      // New fields — safe defaults if not in Firestore
      negativePrompt: data['negative_prompt'] ?? '',
      previewImageUrl: data['preview_image_url'] ?? '',
      likesCount: data['likes_count'] ?? 0,
      copiesCount: data['copies_count'] ?? 0,
      aiModel: data['ai_model'] ?? 'Stable Diffusion',
      aspectRatio: data['aspect_ratio'] ?? '1:1',
      style: data['style'] ?? '',
      categoryName: data['category_name'] ??
          data['category'] ?? '',
    );
  }

  // ─── TO FIRESTORE ─────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'prompt': prompt,
      'category': category,
      'tags': tags,
      'is_trending': isTrending,
      'is_premium': isPremium,
      'order': order,
      'negative_prompt': negativePrompt,
      'preview_image_url': previewImageUrl,
      'likes_count': likesCount,
      'copies_count': copiesCount,
      'ai_model': aiModel,
      'aspect_ratio': aspectRatio,
      'style': style,
      'category_name': categoryName,
    };
  }

  // ─── COPY WITH ────────────────────────────────────
  PromptModel copyWith({
    String? id,
    String? title,
    String? prompt,
    String? category,
    List<String>? tags,
    bool? isTrending,
    bool? isPremium,
    int? order,
    String? negativePrompt,
    String? previewImageUrl,
    int? likesCount,
    int? copiesCount,
    String? aiModel,
    String? aspectRatio,
    String? style,
    String? categoryName,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isTrending: isTrending ?? this.isTrending,
      isPremium: isPremium ?? this.isPremium,
      order: order ?? this.order,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      previewImageUrl:
      previewImageUrl ?? this.previewImageUrl,
      likesCount: likesCount ?? this.likesCount,
      copiesCount: copiesCount ?? this.copiesCount,
      aiModel: aiModel ?? this.aiModel,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      style: style ?? this.style,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}