import 'package:flutter/material.dart';
import '../models/prompt_model.dart';
import '../services/firestore_service.dart';

class PromptProvider extends ChangeNotifier {
  final FirestoreService _firestoreService =
  FirestoreService();

  // ─── STATE ────────────────────────────────────────
  List<PromptModel> _allPrompts = [];
  List<PromptModel> _filteredPrompts = [];
  Set<String> _savedPromptIds = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  // ─── GETTERS ──────────────────────────────────────
  // ✅ allPrompts — fixes: getter 'allPrompts' not defined
  List<PromptModel> get allPrompts => _allPrompts;

  // ✅ filteredPrompts — fixes: getter 'filteredPrompts' not defined
  List<PromptModel> get filteredPrompts =>
      _filteredPrompts;

  // ✅ selectedCategory — fixes: getter 'selectedCategory' not defined
  String get selectedCategory => _selectedCategory;

  bool get isLoading => _isLoading;

  Set<String> get savedPromptIds => _savedPromptIds;

  // ─── LOAD PROMPTS ─────────────────────────────────
  // ✅ loadPrompts() — fixes: method 'loadPrompts' not defined
  Future<void> loadPrompts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPrompts =
      await _firestoreService.getPrompts();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading prompts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── SEARCH ───────────────────────────────────────
  // ✅ searchPrompts() — fixes search functionality
  void searchPrompts(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // ─── FILTER BY CATEGORY ───────────────────────────
  // ✅ filterByCategory() — fixes: method 'filterByCategory' not defined
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  // ─── APPLY FILTER (internal) ──────────────────────
  void _applyFilter() {
    List<PromptModel> result = List.from(_allPrompts);

    // Filter by category
    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.prompt.toLowerCase().contains(query) ||
            p.tags.any((tag) =>
                tag.toLowerCase().contains(query));
      }).toList();
    }

    _filteredPrompts = result;
  }

  // ─── SAVED PROMPTS ────────────────────────────────
  // ✅ loadSavedPromptIds() — load saved ids from Firestore
  Future<void> loadSavedPromptIds(
      String userId) async {
    try {
      final saved = await _firestoreService
          .getSavedPrompts(userId);
      _savedPromptIds =
          saved.map((p) => p['id'] as String).toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved prompts: $e');
    }
  }

  // ✅ isPromptSaved() — fixes: method 'isPromptSaved' not defined
  bool isPromptSaved(String promptId) {
    return _savedPromptIds.contains(promptId);
  }

  // ✅ toggleSavePrompt() — fixes: method 'toggleSavePrompt' not defined
  Future<void> toggleSavePrompt(
      PromptModel prompt, String userId) async {
    final isSaved = isPromptSaved(prompt.id);

    // Optimistic update
    if (isSaved) {
      _savedPromptIds.remove(prompt.id);
    } else {
      _savedPromptIds.add(prompt.id);
    }
    notifyListeners();

    // Sync to Firestore
    try {
      if (isSaved) {
        await _firestoreService.removeSavedPrompt(
            userId, prompt.id);
      } else {
        await _firestoreService.savePrompt(
            userId, prompt);
      }
    } catch (e) {
      // Revert on error
      if (isSaved) {
        _savedPromptIds.add(prompt.id);
      } else {
        _savedPromptIds.remove(prompt.id);
      }
      notifyListeners();
      debugPrint('Error toggling save: $e');
    }
  }

  // ─── CLEAR ────────────────────────────────────────
  void clear() {
    _allPrompts = [];
    _filteredPrompts = [];
    _savedPromptIds = {};
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }
}