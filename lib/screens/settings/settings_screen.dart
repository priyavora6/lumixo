// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../utils/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _imageReadyNotifications = true;
  bool _promotionalNotifications = false;
  String _appVersion = '1.0.0';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load app version
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });

    // Load notification settings
    final notificationService = NotificationService();
    final enabled = await notificationService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Account Section
                    _buildSectionHeader('Account'),
                    _buildAccountCard(user, userProvider),

                    const SizedBox(height: 16),

                    // Notifications Section
                    _buildSectionHeader('Notifications'),
                    _buildNotificationSettings(),

                    const SizedBox(height: 16),

                    // Appearance Section
                    _buildSectionHeader('Appearance'),
                    _buildAppearanceSettings(),

                    const SizedBox(height: 16),

                    // Storage Section
                    _buildSectionHeader('Storage'),
                    _buildStorageSettings(),

                    const SizedBox(height: 16),

                    // Support Section
                    _buildSectionHeader('Support & About'),
                    _buildSupportSettings(),

                    const SizedBox(height: 16),

                    // Legal Section
                    _buildSectionHeader('Legal'),
                    _buildLegalSettings(),

                    const SizedBox(height: 16),

                    // Danger Zone
                    _buildSectionHeader('Account Actions'),
                    _buildDangerZone(),

                    const SizedBox(height: 32),

                    // App Version
                    _buildVersionInfo(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMedium.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountCard(User? user, UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? const Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primary,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Lumixo User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: userProvider.isPremium
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        userProvider.isPremium
                            ? Icons.star
                            : Icons.person,
                        size: 12,
                        color: userProvider.isPremium
                            ? Colors.orange
                            : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userProvider.isPremium ? 'Premium' : 'Free',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: userProvider.isPremium
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.primary,
            ),
            onPressed: () {
              // Navigate to edit profile
              // Navigator.pushNamed(context, AppRoutes.editProfile);
              _showComingSoonDialog('Edit Profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              if (value) {
                await NotificationService().initialize();
              }
            },
            iconColor: AppColors.primary,
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.image,
            title: 'Image Ready Alerts',
            subtitle: 'Notify when image is ready',
            value: _imageReadyNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _imageReadyNotifications = value);
                    if (value) {
                      NotificationService()
                          .subscribeToTopic('image_notifications');
                    } else {
                      NotificationService()
                          .unsubscribeFromTopic('image_notifications');
                    }
                  }
                : null,
            iconColor: Colors.green,
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.local_offer,
            title: 'Promotional Offers',
            subtitle: 'Get deals and discounts',
            value: _promotionalNotifications,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _promotionalNotifications = value);
                    if (value) {
                      NotificationService().subscribeToTopic('promotions');
                    } else {
                      NotificationService()
                          .unsubscribeFromTopic('promotions');
                    }
                  }
                : null,
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              _showComingSoonDialog('Dark Mode');
            },
            iconColor: Colors.purple,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(),
            iconColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.cached,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _showClearCacheDialog(),
            iconColor: Colors.orange,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.download,
            title: 'Download Quality',
            subtitle: 'High Quality',
            onTap: () => _showQualityDialog(),
            iconColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help or contact us',
            onTap: () => _launchURL('https://lumixo.app/support'),
            iconColor: Colors.blue,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Rate us on store',
            onTap: () => _rateApp(),
            iconColor: Colors.amber,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Share with friends',
            onTap: () => _shareApp(),
            iconColor: Colors.green,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About Lumixo',
            subtitle: 'Version $_appVersion',
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
            iconColor: Colors.purple,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Terms and conditions',
            onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
            iconColor: Colors.indigo,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.gavel,
            title: 'Licenses',
            subtitle: 'Open source licenses',
            onTap: () => _showLicensesDialog(),
            iconColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            onTap: () => _showLogoutDialog(),
            iconColor: Colors.orange,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your data',
            onTap: () => _showDeleteAccountDialog(),
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Color iconColor,
  }) {
    final isEnabled = onChanged != null;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isEnabled ? iconColor : Colors.grey,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isEnabled ? AppColors.textDark : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isEnabled
              ? AppColors.textMedium.withOpacity(0.7)
              : Colors.grey,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMedium.withOpacity(0.7),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textMedium,
      ),
      onTap: onTap,
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Lumixo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version $_appVersion',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ by Lumixo Team',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMedium.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', '🇺🇸', true),
            _buildLanguageOption('Hindi', '🇮🇳', false),
            _buildLanguageOption('Spanish', '🇪🇸', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String name, String flag, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        _showComingSoonDialog('Language Change');
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and free up storage space. Your saved images will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    // Implement cache clearing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Download Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('High Quality', 'Best quality, larger file', true),
            _buildQualityOption('Medium Quality', 'Balanced quality & size', false),
            _buildQualityOption('Low Quality', 'Smaller file size', false),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String title, String subtitle, bool isSelected) {
    return RadioListTile<bool>(
      value: true,
      groupValue: isSelected,
      onChanged: (value) {
        Navigator.pop(context);
        _showComingSoonDialog('Quality Settings');
      },
      title: Text(title),
      subtitle: Text(subtitle),
      activeColor: AppColors.primary,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data, images, and subscription will be permanently deleted.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog('Account Deletion');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showLicensesDialog() {
    showLicensePage(
      context: context,
      applicationName: 'Lumixo',
      applicationVersion: _appVersion,
      applicationIcon: const Icon(
        Icons.auto_awesome,
        size: 50,
        color: AppColors.primary,
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Coming Soon'),
        content: Text('$feature will be available in the next update!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Future<void> _rateApp() async {
    // Implement rate app logic
    _showComingSoonDialog('Rate App');
  }

  Future<void> _shareApp() async {
    await Share.share(
      'Check out Lumixo - AI Photo Transform! Download now: https://lumixo.app',
      subject: 'Transform your photos with AI',
    );
  }
}
