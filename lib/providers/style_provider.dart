import 'package:flutter/material.dart';
import '../models/style_model.dart';
import '../services/firestore_service.dart';

class StyleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService =
  FirestoreService();

  List<StyleModel> _styles = [];
  bool _isLoading = false;
  String? _currentCategoryId;

  // ─── GETTERS ──────────────────────────────────────
  List<StyleModel> get styles => _styles;
  bool get isLoading => _isLoading;
  String? get currentCategoryId => _currentCategoryId;

  // ─── LOAD STYLES FOR ONE CATEGORY ─────────────────
  Future<void> loadStylesForCategory(
      String categoryId) async {
    // If same category already loaded, skip
    if (_currentCategoryId == categoryId &&
        _styles.isNotEmpty) return;

    _isLoading = true;
    _currentCategoryId = categoryId;
    notifyListeners();

    try {
      final styles = await _firestoreService.getStyles(categoryId);
      _styles = styles
          .map((s) => s.copyWith(categoryId: categoryId))
          .toList();
    } catch (e) {
      debugPrint('Error loading styles: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── CLEAR ────────────────────────────────────────
  void clear() {
    _styles = [];
    _isLoading = false;
    _currentCategoryId = null;
    notifyListeners();
  }
}
