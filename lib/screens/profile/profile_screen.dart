import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/premium_badge.dart';
import '../../widgets/coin_widget.dart';
import '../../utils/colors.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService =
  FirestoreService();
  List<Map<String, dynamic>> _savedPrompts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrompts();
  }

  Future<void> _loadSavedPrompts() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;
    final prompts = await _firestoreService
        .getSavedPrompts(user.uid);
    setState(() => _savedPrompts = prompts);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout?'),
        content: const Text(
            'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              context.read<UserProvider>().clearUser();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.06),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 45,
                        backgroundImage:
                        user.photoUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                            user.photoUrl)
                            : null,
                        backgroundColor:
                        AppColors.primary
                            .withOpacity(0.2),
                        child: user.photoUrl.isEmpty
                            ? Text(
                          user.name
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color:
                            AppColors.primary,
                          ),
                        )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (user.isPremium)
                        const PremiumBadge(isSmall: false),

                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(
                            '${user.totalEdits}',
                            'Total Edits',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey
                                .withOpacity(0.2),
                          ),
                          _buildStat(
                            '${user.coins}',
                            'Coins 🪙',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey
                                .withOpacity(0.2),
                          ),
                          _buildStat(
                            user.isPremium
                                ? 'Active'
                                : 'Free',
                            'Plan',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Menu items
                _buildMenuItem(
                  '👑',
                  'Upgrade to Premium',
                  'Unlimited edits forever',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.premium),
                  showArrow: true,
                ),

                const SizedBox(height: 12),

                _buildMenuItem(
                  '📁',
                  'My Edit History',
                  'View all past transformations',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.history),
                  showArrow: true,
                ),

                const SizedBox(height: 12),

                _buildMenuItem(
                  '🔖',
                  'Saved Prompts',
                  '${_savedPrompts.length} prompts saved',
                  onTap: () {},
                  showArrow: true,
                ),

                const SizedBox(height: 12),

                _buildMenuItem(
                  '🔔',
                  'Notifications',
                  'Manage alerts',
                  onTap: () {},
                  showArrow: true,
                ),

                const SizedBox(height: 12),

                _buildMenuItem(
                  '🚪',
                  'Logout',
                  'Sign out of your account',
                  onTap: _logout,
                  isDestructive: true,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Lumixo v1.0.0 ✦ Made with ♡',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      String emoji,
      String title,
      String subtitle, {
        required VoidCallback onTap,
        bool showArrow = false,
        bool isDestructive = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.errorColor
                          : AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
          ],
        ),
      ),
    );
  }
}