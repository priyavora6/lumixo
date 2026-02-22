import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/style_model.dart';
import '../models/prompt_model.dart';
import '../models/edit_history_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════
  // APP CONFIG
  // ══════════════════════════════════════════════════

  Future<String> getApiKey() async {
    final doc = await _db
        .collection('app_config')
        .doc('settings')
        .get();
    return doc.data()?['replicate_api_key'] ?? '';
  }

  Future<Map<String, dynamic>> getSettings() async {
    final doc = await _db
        .collection('app_config')
        .doc('settings')
        .get();
    return doc.data() ?? {};
  }

  // ══════════════════════════════════════════════════
  // CATEGORIES
  // ══════════════════════════════════════════════════

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  Future<List<StyleModel>> getStyles(
      String categoryId) async {
    final snapshot = await _db
        .collection('categories')
        .doc(categoryId)
        .collection('styles')
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => StyleModel.fromFirestore(doc))
        .toList();
  }

  // ══════════════════════════════════════════════════
  // PROMPTS
  // ══════════════════════════════════════════════════

  Future<List<PromptModel>> getPrompts() async {
    final snapshot = await _db
        .collection('prompts')
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => PromptModel.fromFirestore(doc))
        .toList();
  }

  Future<List<PromptModel>> getTrendingPrompts() async {
    final snapshot = await _db
        .collection('prompts')
        .where('is_trending', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => PromptModel.fromFirestore(doc))
        .toList();
  }

  // ══════════════════════════════════════════════════
  // SAVED PROMPTS
  // ✅ FIXED — correct method signatures
  // ══════════════════════════════════════════════════

  // ✅ savePrompt — takes userId + full PromptModel
  Future<void> savePrompt(
      String userId,
      PromptModel prompt,
      ) async {
    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('saved_prompts')
        .doc(prompt.id)
        .set({
      'id': prompt.id,
      'title': prompt.title,
      'prompt': prompt.prompt,
      'category': prompt.category,
      'is_premium': prompt.isPremium,
      'saved_at': FieldValue.serverTimestamp(),
    });
  }

  // ✅ removeSavedPrompt — takes userId + promptId (String)
  Future<void> removeSavedPrompt(
      String userId,
      String promptId,
      ) async {
    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('saved_prompts')
        .doc(promptId)
        .delete();
  }

  // ✅ getSavedPrompts — returns List<Map>
  Future<List<Map<String, dynamic>>> getSavedPrompts(
      String userId,
      ) async {
    final snapshot = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('saved_prompts')
        .orderBy('saved_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  // ✅ isPromptSaved — check if a prompt is saved
  Future<bool> isPromptSaved(
      String userId,
      String promptId,
      ) async {
    final doc = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('saved_prompts')
        .doc(promptId)
        .get();
    return doc.exists;
  }

  // ══════════════════════════════════════════════════
  // USER DATA
  // ══════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getUserData(
      String userId) async {
    final doc = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .get();
    return doc.data();
  }

  Future<void> createUser(
      String userId,
      Map<String, dynamic> data,
      ) async {
    final doc = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .get();
    if (!doc.exists) {
      await _db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .set(data);
    }
  }

  // ══════════════════════════════════════════════════
  // EDIT LIMITS & COINS
  // ══════════════════════════════════════════════════

  Future<Map<String, dynamic>> checkEditLimit(
      String userId) async {
    final settings = await getSettings();
    final freeEditsPerDay =
        settings['free_edits_per_day'] ?? 3;
    final coinsPerEdit =
        settings['coins_per_edit'] ?? 3;

    final userData = await getUserData(userId);
    if (userData == null) {
      return {'canEdit': false, 'reason': 'User not found'};
    }

    final isPremium = userData['is_premium'] ?? false;
    if (isPremium) {
      return {'canEdit': true, 'reason': 'premium'};
    }

    final today = DateTime.now()
        .toIso8601String()
        .substring(0, 10);
    final lastEditDate = userData['last_edit_date'] ?? '';
    final freeEditsToday = lastEditDate == today
        ? (userData['free_edits_today'] ?? 0)
        : 0;

    if (freeEditsToday < freeEditsPerDay) {
      return {
        'canEdit': true,
        'reason': 'free',
        'editsLeft': freeEditsPerDay - freeEditsToday,
      };
    }

    final coins = userData['coins'] ?? 0;
    if (coins >= coinsPerEdit) {
      return {
        'canEdit': true,
        'reason': 'coins',
        'coins': coins,
      };
    }

    return {
      'canEdit': false,
      'reason': 'limit_reached',
      'editsLeft': 0,
    };
  }

  Future<void> incrementEditCount(String userId) async {
    final today = DateTime.now()
        .toIso8601String()
        .substring(0, 10);
    final userData = await getUserData(userId);
    final lastEditDate =
        userData?['last_edit_date'] ?? '';
    final freeEditsToday = lastEditDate == today
        ? (userData?['free_edits_today'] ?? 0)
        : 0;

    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .update({
      'free_edits_today': freeEditsToday + 1,
      'last_edit_date': today,
      'total_edits': FieldValue.increment(1),
    });
  }

  Future<void> useCoinsForEdit(String userId) async {
    final settings = await getSettings();
    final coinsPerEdit =
        settings['coins_per_edit'] ?? 3;

    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .update({
      'coins': FieldValue.increment(-coinsPerEdit),
      'total_edits': FieldValue.increment(1),
    });
  }

  Future<void> addCoins(
      String userId, int amount) async {
    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .update({
      'coins': FieldValue.increment(amount),
    });
  }

  // ══════════════════════════════════════════════════
  // PREMIUM
  // ══════════════════════════════════════════════════

  Future<void> updatePremium(
      String userId,
      bool isYearly,
      ) async {
    final expiry = isYearly
        ? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 30));

    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .update({
      'is_premium': true,
      'premium_expiry': Timestamp.fromDate(expiry),
    });
  }

  // ══════════════════════════════════════════════════
  // EDIT HISTORY
  // ══════════════════════════════════════════════════

  Future<void> saveEditHistory({
    required String userId,
    required String originalImage,
    required String resultImage,
    required String styleName,
    required String category,
    required bool isPremium,
  }) async {
    final settings = await getSettings();
    final freeHistoryDays =
        settings['free_history_days'] ?? 30;

    final expiresAt = isPremium
        ? null
        : Timestamp.fromDate(DateTime.now()
        .add(Duration(days: freeHistoryDays)));

    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('edits')
        .add({
      'original_image': originalImage,
      'result_image': resultImage,
      'style_name': styleName,
      'category': category,
      'created_at': FieldValue.serverTimestamp(),
      'expires_at': expiresAt,
    });
  }

  Future<List<EditHistoryModel>> getEditHistory(
      String userId,
      bool isPremium,
      ) async {
    final snapshot = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('edits')
        .orderBy('created_at', descending: true)
        .get();

    final now = DateTime.now();
    return snapshot.docs
        .map((doc) => EditHistoryModel.fromFirestore(doc))
        .where((edit) {
      if (isPremium) return true;
      if (edit.expiresAt == null) return true;
      return edit.expiresAt!.isAfter(now);
    }).toList();
  }

  Future<void> deleteExpiredEdits(
      String userId) async {
    final now = Timestamp.now();
    final snapshot = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('edits')
        .where('expires_at', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteEdit(
      String userId,
      String editId,
      ) async {
    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('edits')
        .doc(editId)
        .delete();
  }

  // ══════════════════════════════════════════════════
  // FCM TOKEN
  // ══════════════════════════════════════════════════

  Future<void> updateFcmToken(
      String userId,
      String token,
      ) async {
    await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .update({'fcm_token': token});
  }
}