import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utility class for admin setup and management
class AdminSetup {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminSetup({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ensures the current logged-in user has an admin role in Firestore
  /// Call this after logging in with admin credentials
  Future<void> ensureAdminRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create new admin user document
      await userDoc.set({
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? 'Admin',
        'role': 'admin',
        'status': 'active',
        'lastLogin': DateTime.now().toIso8601String(),
      });
      print('✅ Created admin user document for: ${user.email}');
    } else {
      // Update existing user to admin role
      await userDoc.update({
        'role': 'admin',
        'lastLogin': DateTime.now().toIso8601String(),
      });
      print('✅ Updated user to admin role: ${user.email}');
    }
  }

  /// Check if current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    return doc.data()?['role'] == 'admin';
  }

  /// Get admin setup status for debugging
  Future<Map<String, dynamic>> getAdminStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'signedIn': false,
        'uid': null,
        'email': null,
        'hasUserDoc': false,
        'role': null,
        'isAdmin': false,
      };
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    return {
      'signedIn': true,
      'uid': user.uid,
      'email': user.email,
      'hasUserDoc': doc.exists,
      'role': data?['role'] ?? 'none',
      'isAdmin': data?['role'] == 'admin',
    };
  }
}

/// Provider for AdminSetup
final adminSetupProvider = Provider<AdminSetup>((ref) {
  return AdminSetup();
});
