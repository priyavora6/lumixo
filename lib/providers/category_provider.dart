import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/style_model.dart';
import '../services/firestore_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CategoryModel> _categories = [];
  List<StyleModel> _styles = [];
  CategoryModel? _selectedCategory;
  StyleModel? _selectedStyle;
  bool _isLoadingCategories = false;
  bool _isLoadingStyles = false;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<StyleModel> get styles => _styles;
  CategoryModel? get selectedCategory => _selectedCategory;
  StyleModel? get selectedStyle => _selectedStyle;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingStyles => _isLoadingStyles;

  // Load categories
  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;

    _isLoadingCategories = true;
    notifyListeners();

    _categories = await _firestoreService.getCategories();

    _isLoadingCategories = false;
    notifyListeners();
  }

  // Load styles for category
  Future<void> loadStyles(String categoryId) async {
    _isLoadingStyles = true;
    _styles = [];
    notifyListeners();

    _styles = await _firestoreService.getStyles(categoryId);

    _isLoadingStyles = false;
    notifyListeners();
  }

  // Select category
  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Select style
  void selectStyle(StyleModel style) {
    _selectedStyle = style;
    notifyListeners();
  }

  // Get surprise me style
  StyleModel? getSurpriseStyle() {
    if (_styles.isEmpty) return null;
    _styles.shuffle();
    return _styles.first;
  }

  // Clear selected
  void clearSelected() {
    _selectedCategory = null;
    _selectedStyle = null;
    notifyListeners();
  }
}