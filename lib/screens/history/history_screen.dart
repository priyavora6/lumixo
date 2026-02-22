import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/edit_history_model.dart';
import '../../widgets/premium_badge.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService =
  FirestoreService();
  List<EditHistoryModel> _edits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    // Delete expired first
    await _firestoreService
        .deleteExpiredEdits(user.uid);

    final edits = await _firestoreService
        .getEditHistory(user.uid, user.isPremium);

    setState(() {
      _edits = edits;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '📁 My Edits',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isPremium)
                              const PremiumBadge(),
                          ],
                        ),
                        Text(
                          isPremium
                              ? 'Forever saved ✨'
                              : 'Saved for 30 days',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${_edits.length} edits',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Free user warning
              if (!isPremium && _edits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      20, 12, 20, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.premium),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange
                              .withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('⚠️',
                              style: TextStyle(
                                  fontSize: 16)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Free edits deleted after 30 days. Go Premium to save forever!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
                    : _edits.isEmpty
                    ? _buildEmpty()
                    : GridView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _edits.length,
                  itemBuilder:
                      (context, index) {
                    return _buildEditCard(
                        _edits[index],
                        isPremium);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditCard(
      EditHistoryModel edit,
      bool isPremium,
      ) {
    final int daysLeft = edit.daysLeft;
    final bool expiringSoon =
        !isPremium && daysLeft <= 5;

    return GestureDetector(
      onTap: () => _showEditDetail(edit),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Result image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: edit.resultImage,
                fit: BoxFit.cover,
              ),
            ),

            // Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Style name
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                edit.styleName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Expiry warning
            if (expiringSoon)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                    Colors.orange.withOpacity(0.9),
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$daysLeft days left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷',
              style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'No edits yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Transform your first photo to see it here',
            style: TextStyle(
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, AppRoutes.home),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Text(
                'Start Transforming ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDetail(EditHistoryModel edit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => Container(
        height:
        MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: edit.resultImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${edit.category} • ${edit.styleName}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                        Icons.download_rounded),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _firestoreService
                          .deleteEdit(
                        context
                            .read<UserProvider>()
                            .user!
                            .uid,
                        edit.id,
                      );
                      Navigator.pop(context);
                      _loadHistory();
                    },
                    icon: const Icon(
                        Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}