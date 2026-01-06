import 'package:cloud_firestore/cloud_firestore.dart'; // NETWORK & DATABASE: Firebase Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart'; // SECURITY: Firebase Authentication
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';

// --- Custom Exception for better error messages ---

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;

  /// Convert Firebase errors to user-friendly messages
  static AppException fromFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppException('No account found with this email address.');
      case 'wrong-password':
        return AppException('Incorrect password. Please try again.');
      case 'invalid-credential':
        return AppException(
          'Invalid email or password. Please check your credentials.',
        );
      case 'email-already-in-use':
        return AppException('An account already exists with this email.');
      case 'weak-password':
        return AppException('Password is too weak. Use at least 6 characters.');
      case 'invalid-email':
        return AppException('Please enter a valid email address.');
      case 'user-disabled':
        return AppException('This account has been disabled. Contact support.');
      case 'too-many-requests':
        return AppException('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return AppException('Network error. Please check your connection.');
      default:
        return AppException('Authentication failed. Please try again.');
    }
  }

  static AppException fromFirestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException(
          'You don\'t have permission to perform this action. Please sign in.',
        );
      case 'unavailable':
        return AppException(
          'Service temporarily unavailable. Please try again.',
        );
      case 'not-found':
        return AppException('The requested data was not found.');
      case 'cancelled':
        return AppException('Operation was cancelled.');
      default:
        return AppException('An error occurred. Please try again.');
    }
  }
}

// --- Auth Repository ---

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<AppUser?> getCurrentUserData();
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
}

// SECURITY: Repository handling User Authentication
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._auth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<AppUser?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return AppUser.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create user doc
      final appUser = AppUser(id: cred.user!.uid, email: email, role: 'user');
      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(appUser.toJson());
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// --- Database Repository ---

abstract class DatabaseRepository {
  Stream<List<MenuPackage>> getPackages();
  Future<void> createBooking(Booking booking);
  Stream<List<Booking>> getUserBookings(String userId);
  Stream<List<Booking>> getAllBookings(); // Admin
  Future<List<Booking>> getBookingsForDate(
    DateTime date,
  ); // For capacity checking
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> cancelBooking(String bookingId);
  Future<void> addPackage(MenuPackage package);
  Future<void> updateBooking(Booking booking);
  Future<void> updateUser(AppUser user);
  Stream<List<AppUser>> getAllUsers();
  Future<void> deleteUser(String userId);
}

// DATABASE: Repository handling generic Database operations (Firestore implementation)
class FirestoreDatabaseRepository implements DatabaseRepository {
  final FirebaseFirestore _firestore;

  FirestoreDatabaseRepository(this._firestore);

  @override
  Stream<List<MenuPackage>> getPackages() {
    // DATABASE LOGIC: Real-time stream of menu packages from Firestore collection 'packages'
    return _firestore
        .collection('packages')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MenuPackage.fromJson(doc.data()))
              .toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw AppException.fromFirestore(error);
          }
          throw AppException('Failed to load menu packages.');
        });
  }

  @override
  Future<void> createBooking(Booking booking) async {
    try {
      // DATABASE LOGIC: Create a new booking document in 'bookings' collection
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toJson());
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Stream<List<Booking>> getUserBookings(String userId) {
    // DATABASE LOGIC: Query 'bookings' collection filtering by userId
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromJson(doc.data()))
              .toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw AppException.fromFirestore(error);
          }
          throw AppException('Failed to load your bookings.');
        });
  }

  @override
  Stream<List<Booking>> getAllBookings() {
    // DATABASE LOGIC: Admin function to fetch all bookings ordered by recent date
    return _firestore
        .collection('bookings')
        .orderBy('eventDateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromJson(doc.data()))
              .toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw AppException.fromFirestore(error);
          }
          throw AppException('Failed to load bookings.');
        });
  }

  @override
  Future<List<Booking>> getBookingsForDate(DateTime date) async {
    try {
      // LOGIC: Calculate start and end of day for precise date querying
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('bookings')
          .where(
            'eventDateTime',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('eventDateTime', isLessThan: endOfDay.toIso8601String())
          .get();

      // Filter out cancelled bookings
      return snapshot.docs
          .map((doc) => Booking.fromJson(doc.data()))
          .where((booking) => booking.status != 'cancelled')
          .toList();
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> addPackage(MenuPackage package) async {
    try {
      await _firestore
          .collection('packages')
          .doc(package.id)
          .set(package.toJson());
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toJson());
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }

  @override
  Stream<List<AppUser>> getAllUsers() {
    // DATABASE LOGIC: Real-time stream of all users for Admin management
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppUser.fromJson(doc.data()))
              .toList();
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw AppException.fromFirestore(error);
          }
          throw AppException('Failed to load users.');
        });
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } on FirebaseException catch (e) {
      throw AppException.fromFirestore(e);
    }
  }
}

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return FirestoreDatabaseRepository(FirebaseFirestore.instance);
});

// Provides real-time updates for the current logged-in user's data
final currentAppUserStreamProvider = StreamProvider<AppUser?>((ref) {
  final authUserAsync = ref.watch(authStateProvider);

  return authUserAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return AppUser.fromJson(doc.data()!);
          });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
