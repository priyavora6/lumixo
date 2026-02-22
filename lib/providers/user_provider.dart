import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService =
  FirestoreService();

  UserModel? _user;
  bool _isLoading = false;

  // ─── GETTERS ──────────────────────────────────────
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isPremium => _user?.isPremium ?? false;
  int get coins => _user?.coins ?? 0;
  int get freeEditsToday => _user?.freeEditsToday ?? 0;
  int get editsLeft =>
      (3 - freeEditsToday).clamp(0, 3);

  // ─── LOAD USER ────────────────────────────────────
  Future<void> loadUser() async {
    final firebaseUser =
        FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // ✅ FIXED — getUserData returns Map, convert to UserModel
      final Map<String, dynamic>? data =
      await _firestoreService
          .getUserData(firebaseUser.uid);

      if (data != null) {
        // ✅ Convert Map → UserModel using fromMap factory
        _user = UserModel.fromMap(
            firebaseUser.uid, data);
      } else {
        // New user — create default data
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '',
          coins: 10,
          isPremium: false,
          premiumExpiry: null,
          freeEditsToday: 0,
          lastEditDate: '',
          totalEdits: 0,
        );

        await _firestoreService.createUser(
          firebaseUser.uid,
          newUser.toMap(),
        );

        _user = newUser;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── REFRESH USER ─────────────────────────────────
  Future<void> refreshUser() async {
    await loadUser();
  }

  // ─── UPDATE COINS LOCALLY ─────────────────────────
  void updateCoinsLocally(int newCoins) {
    if (_user == null) return;
    _user = _user!.copyWith(coins: newCoins);
    notifyListeners();
  }

  // ─── SET PREMIUM LOCALLY ──────────────────────────
  void setPremiumLocally() {
    if (_user == null) return;
    _user = _user!.copyWith(isPremium: true);
    notifyListeners();
  }

  // ─── CLEAR USER ───────────────────────────────────
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}