// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuPackage _$MenuPackageFromJson(Map<String, dynamic> json) => _MenuPackage(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  pricePerGuest: (json['pricePerGuest'] as num).toDouble(),
  isAvailable: json['isAvailable'] as bool? ?? true,
  dietaryInfo:
      (json['dietaryInfo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MenuPackageToJson(_MenuPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'pricePerGuest': instance.pricePerGuest,
      'isAvailable': instance.isAvailable,
      'dietaryInfo': instance.dietaryInfo,
    };

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  role: json['role'] as String? ?? 'user',
  status: json['status'] as String? ?? 'active',
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phoneNumber': instance.phoneNumber,
  'role': instance.role,
  'status': instance.status,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'avatarUrl': instance.avatarUrl,
};

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  menuPackageId: json['menuPackageId'] as String,
  menuPackageName: json['menuPackageName'] as String,
  packageImageUrl: json['packageImageUrl'] as String,
  eventDateTime: DateTime.parse(json['eventDateTime'] as String),
  numberOfGuests: (json['numberOfGuests'] as num).toInt(),
  basePricePerGuest: (json['basePricePerGuest'] as num).toDouble(),
  serviceCharge: (json['serviceCharge'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  status: json['status'] as String? ?? 'pending',
  specialRequests: json['specialRequests'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'menuPackageId': instance.menuPackageId,
  'menuPackageName': instance.menuPackageName,
  'packageImageUrl': instance.packageImageUrl,
  'eventDateTime': instance.eventDateTime.toIso8601String(),
  'numberOfGuests': instance.numberOfGuests,
  'basePricePerGuest': instance.basePricePerGuest,
  'serviceCharge': instance.serviceCharge,
  'totalPrice': instance.totalPrice,
  'status': instance.status,
  'specialRequests': instance.specialRequests,
  'createdAt': instance.createdAt.toIso8601String(),
};
