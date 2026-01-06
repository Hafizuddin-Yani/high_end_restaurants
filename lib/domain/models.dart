import 'package:freezed_annotation/freezed_annotation.dart'; // 3RD PARTY: Code generation for immutable classes
import 'package:flutter/foundation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// DATABASE MODEL: Represents a Menu Package (stored in 'packages' collection)
@freezed
abstract class MenuPackage with _$MenuPackage {
  const factory MenuPackage({
    required String id, // Primary Key
    required String name,
    required String description,
    required String imageUrl, // URL to image in storage
    required double pricePerGuest,
    @Default(true) bool isAvailable,
    @Default([]) List<String> dietaryInfo, // e.g., "Vegetarian", "GF"
  }) = _MenuPackage;

  factory MenuPackage.fromJson(Map<String, dynamic> json) =>
      _$MenuPackageFromJson(json);
}

// DATABASE MODEL: Represents a User (stored in 'users' collection)
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id, // Primary Key (matches Auth UID)
    required String email,
    String? name,
    String? phoneNumber,
    @Default('user')
    String role, // 'admin', 'editor', 'user' - Authorization level
    @Default('active') String status, // 'active', 'inactive', 'banned'
    DateTime? lastLogin,
    String? avatarUrl,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

// DATABASE MODEL: Represents a Booking (stored in 'bookings' collection)
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id, // Primary Key
    required String userId, // Foreign Key: Links to AppUser
    required String menuPackageId, // Foreign Key: Links to MenuPackage
    required String menuPackageName, // Snapshot of package name
    required String packageImageUrl, // Snapshot for history
    required DateTime eventDateTime,
    required int numberOfGuests,
    required double basePricePerGuest, // Snapshot of price at booking time
    required double serviceCharge,
    required double totalPrice,
    @Default('pending') String status, // 'pending', 'confirmed', 'cancelled'
    String? specialRequests,
    required DateTime createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
