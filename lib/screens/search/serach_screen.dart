// lib/screens/search/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumixo/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _categories = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _selectedCategory = 'all';

  final List<String> _popularSearches = [
    'Portrait',
    'Wedding',
    'Business',
    'Holi',
    'Diwali',
    'Birthday',
    'Instagram',
    'Bollywood',
    'Anime',
    'Fantasy',
    'Logo',
    'Watercolor',
  ];

  // Category colors matching your theme
  final List<Color> _categoryColors = [
    const Color(0xFFE8A0B4), // pink
    const Color(0xFFB5D5A8), // green
    const Color(0xFFB8D4F0), // blue
    const Color(0xFFD4B8F0), // purple
    const Color(0xFFFFB830), // orange
    const Color(0xFFF0B8D4), // rose
    const Color(0xFF6BCB77), // success green
    const Color(0xFFFFD700), // gold
    const Color(0xFFFF6B6B), // red
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _db
          .collection('categories')
          .where('is_active', isEqualTo: true)
          .orderBy('order')
          .get();

      setState(() {
        _categories = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      List<Map<String, dynamic>> allResults = [];

      final categoriesSnapshot = await _db
          .collection('categories')
          .where('is_active', isEqualTo: true)
          .get();

      for (final catDoc in categoriesSnapshot.docs) {
        final catData = catDoc.data();
        final catId = catDoc.id;

        if (_selectedCategory != 'all' && catId != _selectedCategory) {
          continue;
        }

        final stylesSnapshot = await _db
            .collection('categories')
            .doc(catId)
            .collection('styles')
            .where('is_active', isEqualTo: true)
            .get();

        final lowerQuery = query.toLowerCase();

        for (final styleDoc in stylesSnapshot.docs) {
          final styleData = styleDoc.data();
          final name = (styleData['name'] ?? '').toString().toLowerCase();
          final prompt = (styleData['prompt'] ?? '').toString().toLowerCase();

          if (name.contains(lowerQuery) || prompt.contains(lowerQuery)) {
            allResults.add({
              'id': styleDoc.id,
              'category_id': catId,
              'category_name': catData['name'] ?? '',
              'category_icon': catData['icon'] ?? '📁',
              ...styleData,
            });
          }
        }
      }

      // Sort by relevance
      allResults.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        final lowerQuery = query.toLowerCase();

        if (aName.startsWith(lowerQuery) && !bName.startsWith(lowerQuery)) return -1;
        if (!aName.startsWith(lowerQuery) && bName.startsWith(lowerQuery)) return 1;
        return 0;
      });

      setState(() {
        _results = allResults;
        _isLoading = false;
      });

      // Save recent
      if (!_recentSearches.contains(query.trim())) {
        _recentSearches.insert(0, query.trim());
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      }
    } catch (e) {
      print('Search error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasSearched
                    ? _results.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults()
                    : _buildSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SEARCH BAR ──
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 10),

          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (val) {
                  if (val.length >= 2) {
                    _search(val);
                  } else if (val.isEmpty) {
                    setState(() {
                      _results = [];
                      _hasSearched = false;
                    });
                  }
                },
                onSubmitted: _search,
                style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search styles, prompts...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary.withOpacity(0.5),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _results = [];
                        _hasSearched = false;
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY FILTER ──
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip('all', '🔍', 'All'),
          ..._categories.map((cat) => _filterChip(
            cat['id'],
            cat['icon'] ?? '📁',
            cat['name'] ?? '',
          )),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String icon, String label) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = id);
        if (_searchController.text.isNotEmpty) {
          _search(_searchController.text);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMedium,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SUGGESTIONS ──
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🕐 Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _recentSearches.clear()),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _search(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 6),
                        Text(
                          search,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular
          const Text(
            '🔥 Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _search(search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    search,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Browse Categories
          const Text(
            '📂 Browse Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ..._categories.asMap().entries.map((entry) {
            return _buildCategoryRow(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> cat, int index) {
    final color = _categoryColors[index % _categoryColors.length];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = cat['id']);
        _searchController.text = cat['name'] ?? '';
        _search(cat['name'] ?? '');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(cat['icon'] ?? '📁', style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontSize: 15,
                    ),
                  ),
                  if (cat['description'] != null)
                    Text(
                      cat['description'],
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // ── SEARCH RESULTS ──
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${_results.length} results found',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return _buildResultCard(_results[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
    final color = _categoryColors[index % _categoryColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, result);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
                image: result['image_url'] != null &&
                    result['image_url'].toString().isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(result['image_url']),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: result['image_url'] == null ||
                  result['image_url'].toString().isEmpty
                  ? Center(
                child: Text(
                  result['category_icon'] ?? '🎨',
                  style: const TextStyle(fontSize: 24),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (result['is_premium'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '👑 PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['prompt'] ?? '',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${result['category_icon'] ?? ''} ${result['category_name'] ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Copy
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: result['prompt'] ?? ''),
                );
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Prompt copied!'),
                    backgroundColor: AppColors.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LOADING ──
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── EMPTY ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _results = [];
                _hasSearched = false;
              });
              _focusNode.requestFocus();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}