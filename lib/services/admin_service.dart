// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────
  // ADMIN EMAILS - Add your admin emails here
  // ─────────────────────────────────────────────────
  static const List<String> _adminEmails = [
    'admin@lumixo.com',
    'developer@lumixo.com',
    'your-email@gmail.com', // Add your email here
    // Add more admin emails as needed
  ];

  // ─────────────────────────────────────────────────
  // SECRET ADMIN CODE (Optional extra security)
  // ─────────────────────────────────────────────────
  static const String _adminSecretCode = 'LUMIXO_ADMIN_2024';

  // ─────────────────────────────────────────────────
  // CHECK IF CURRENT USER IS ADMIN
  // ─────────────────────────────────────────────────
  bool get isCurrentUserAdmin {
    final user = _auth.currentUser;
    if (user == null) return false;
    return isAdminEmail(user.email ?? '');
  }

  // ─────────────────────────────────────────────────
  // CHECK IF EMAIL IS ADMIN
  // ─────────────────────────────────────────────────
  bool isAdminEmail(String email) {
    return _adminEmails.contains(email.toLowerCase().trim());
  }

  // ─────────────────────────────────────────────────
  // VERIFY ADMIN SECRET CODE
  // ─────────────────────────────────────────────────
  bool verifyAdminCode(String code) {
    return code == _adminSecretCode;
  }

  // ─────────────────────────────────────────────────
  // CHECK ADMIN FROM FIRESTORE (More secure)
  // ─────────────────────────────────────────────────
  Future<bool> isAdminFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check in users collection
      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data?['is_admin'] == true || data?['role'] == 'admin') {
          return true;
        }
      }

      // Check in admins collection
      final adminDoc = await _db.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) {
        return true;
      }

      // Fallback to email check
      return isAdminEmail(user.email ?? '');
    } catch (e) {
      // Fallback to email check if Firestore fails
      return isAdminEmail(user.email ?? '');
    }
  }

  // ─────────────────────────────────────────────────
  // GET CURRENT USER EMAIL
  // ─────────────────────────────────────────────────
  String? get currentUserEmail => _auth.currentUser?.email;

  // ─────────────────────────────────────────────────
  // LOG ADMIN ACTION (For audit)
  // ─────────────────────────────────────────────────
  Future<void> logAdminAction(String action, {Map<String, dynamic>? details}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('admin_logs').add({
        'user_id': user.uid,
        'email': user.email,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to log admin action: $e');
    }
  }
}