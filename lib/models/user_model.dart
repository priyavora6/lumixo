import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final int coins;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final int freeEditsToday;
  final String lastEditDate;
  final int totalEdits;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.coins,
    required this.isPremium,
    required this.premiumExpiry,
    required this.freeEditsToday,
    required this.lastEditDate,
    required this.totalEdits,
  });

  // ─── FROM FIRESTORE MAP ───────────────────────────
  // ✅ FIXED — fromMap factory converts Map → UserModel
  factory UserModel.fromMap(
      String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      coins: data['coins'] ?? 0,
      isPremium: data['is_premium'] ?? false,
      premiumExpiry: data['premium_expiry'] != null
          ? (data['premium_expiry'] as Timestamp)
          .toDate()
          : null,
      freeEditsToday: data['free_edits_today'] ?? 0,
      lastEditDate: data['last_edit_date'] ?? '',
      totalEdits: data['total_edits'] ?? 0,
    );
  }

  // ─── FROM FIRESTORE DOC ───────────────────────────
  factory UserModel.fromFirestore(
      DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(doc.id, data);
  }

  // ─── TO MAP (for Firestore) ───────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'coins': coins,
      'is_premium': isPremium,
      'premium_expiry': premiumExpiry != null
          ? Timestamp.fromDate(premiumExpiry!)
          : null,
      'free_edits_today': freeEditsToday,
      'last_edit_date': lastEditDate,
      'total_edits': totalEdits,
    };
  }

  // ─── COPY WITH ────────────────────────────────────
  // ✅ FIXED — copyWith allows updating single fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? coins,
    bool? isPremium,
    DateTime? premiumExpiry,
    int? freeEditsToday,
    String? lastEditDate,
    int? totalEdits,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      freeEditsToday:
      freeEditsToday ?? this.freeEditsToday,
      lastEditDate: lastEditDate ?? this.lastEditDate,
      totalEdits: totalEdits ?? this.totalEdits,
    );
  }
}