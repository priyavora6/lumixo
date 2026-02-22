// lib/screens/admin/admin_panel_screen.dart

import 'package:flutter/material.dart';
import 'package:lumixo/services/admin_service.dart';
import 'package:lumixo/screens/admin/seed_data_screen.dart';
import 'package:lumixo/utils/colors.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AdminService _adminService = AdminService();
  bool _isVerified = false;
  bool _isLoading = true;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    setState(() => _isLoading = true);

    final isAdmin = await _adminService.isAdminFromFirestore();

    setState(() {
      _isVerified = isAdmin;
      _isLoading = false;
    });

    if (!isAdmin) {
      // Show access denied
      _showAccessDenied();
    }
  }

  void _showAccessDenied() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Text('🔒', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text('Access Denied'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You don\'t have admin access.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter admin code to continue:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter secret code',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _verifyCode() {
    if (_adminService.verifyAdminCode(_codeController.text.trim())) {
      Navigator.pop(context);
      setState(() => _isVerified = true);
      _adminService.logAdminAction('admin_access_via_code');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Admin access granted!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Invalid admin code!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20),
                Text(
                  'Verifying admin access...',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isVerified) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 20),
                const Text(
                  'Admin Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Admin Panel'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Info Card
                _buildAdminInfoCard(),

                const SizedBox(height: 24),

                const Text(
                  '⚙️ Admin Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 16),

                // Seed Database
                _buildAdminActionCard(
                  icon: '🌱',
                  title: 'Seed Database',
                  subtitle: 'Add all categories & styles to Firestore',
                  color: Colors.orange,
                  onTap: () {
                    _adminService.logAdminAction('opened_seed_screen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SeedDataScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Manage Users
                _buildAdminActionCard(
                  icon: '👥',
                  title: 'Manage Users',
                  subtitle: 'View and manage user accounts',
                  color: Colors.blue,
                  onTap: () {
                    _showComingSoon('User Management');
                  },
                ),

                const SizedBox(height: 12),

                // View Analytics
                _buildAdminActionCard(
                  icon: '📊',
                  title: 'Analytics',
                  subtitle: 'View app usage statistics',
                  color: Colors.green,
                  onTap: () {
                    _showComingSoon('Analytics');
                  },
                ),

                const SizedBox(height: 12),

                // Manage Categories
                _buildAdminActionCard(
                  icon: '📁',
                  title: 'Manage Categories',
                  subtitle: 'Add, edit or remove categories',
                  color: Colors.purple,
                  onTap: () {
                    _showComingSoon('Category Management');
                  },
                ),

                const SizedBox(height: 12),

                // App Config
                _buildAdminActionCard(
                  icon: '⚙️',
                  title: 'App Configuration',
                  subtitle: 'Update app settings & API keys',
                  color: Colors.teal,
                  onTap: () {
                    _showComingSoon('App Configuration');
                  },
                ),

                const SizedBox(height: 12),

                // Admin Logs
                _buildAdminActionCard(
                  icon: '📋',
                  title: 'Admin Logs',
                  subtitle: 'View admin activity history',
                  color: Colors.indigo,
                  onTap: () {
                    _showComingSoon('Admin Logs');
                  },
                ),

                const SizedBox(height: 30),

                // Warning
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Production Warning',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              'Be careful with admin actions. They affect all users.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _adminService.currentUserEmail ?? 'admin@lumixo.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '✓ Verified',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 $feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}