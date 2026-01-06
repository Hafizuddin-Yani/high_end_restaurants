// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuPackage implements DiagnosticableTreeMixin {

 String get id; String get name; String get description; String get imageUrl; double get pricePerGuest; bool get isAvailable; List<String> get dietaryInfo;
/// Create a copy of MenuPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPackageCopyWith<MenuPackage> get copyWith => _$MenuPackageCopyWithImpl<MenuPackage>(this as MenuPackage, _$identity);

  /// Serializes this MenuPackage to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MenuPackage'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('pricePerGuest', pricePerGuest))..add(DiagnosticsProperty('isAvailable', isAvailable))..add(DiagnosticsProperty('dietaryInfo', dietaryInfo));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.pricePerGuest, pricePerGuest) || other.pricePerGuest == pricePerGuest)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&const DeepCollectionEquality().equals(other.dietaryInfo, dietaryInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,pricePerGuest,isAvailable,const DeepCollectionEquality().hash(dietaryInfo));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MenuPackage(id: $id, name: $name, description: $description, imageUrl: $imageUrl, pricePerGuest: $pricePerGuest, isAvailable: $isAvailable, dietaryInfo: $dietaryInfo)';
}


}

/// @nodoc
abstract mixin class $MenuPackageCopyWith<$Res>  {
  factory $MenuPackageCopyWith(MenuPackage value, $Res Function(MenuPackage) _then) = _$MenuPackageCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String imageUrl, double pricePerGuest, bool isAvailable, List<String> dietaryInfo
});




}
/// @nodoc
class _$MenuPackageCopyWithImpl<$Res>
    implements $MenuPackageCopyWith<$Res> {
  _$MenuPackageCopyWithImpl(this._self, this._then);

  final MenuPackage _self;
  final $Res Function(MenuPackage) _then;

/// Create a copy of MenuPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? pricePerGuest = null,Object? isAvailable = null,Object? dietaryInfo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,pricePerGuest: null == pricePerGuest ? _self.pricePerGuest : pricePerGuest // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,dietaryInfo: null == dietaryInfo ? _self.dietaryInfo : dietaryInfo // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPackage].
extension MenuPackagePatterns on MenuPackage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPackage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPackage value)  $default,){
final _that = this;
switch (_that) {
case _MenuPackage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPackage value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPackage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String imageUrl,  double pricePerGuest,  bool isAvailable,  List<String> dietaryInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPackage() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.pricePerGuest,_that.isAvailable,_that.dietaryInfo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String imageUrl,  double pricePerGuest,  bool isAvailable,  List<String> dietaryInfo)  $default,) {final _that = this;
switch (_that) {
case _MenuPackage():
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.pricePerGuest,_that.isAvailable,_that.dietaryInfo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String imageUrl,  double pricePerGuest,  bool isAvailable,  List<String> dietaryInfo)?  $default,) {final _that = this;
switch (_that) {
case _MenuPackage() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.imageUrl,_that.pricePerGuest,_that.isAvailable,_that.dietaryInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuPackage with DiagnosticableTreeMixin implements MenuPackage {
  const _MenuPackage({required this.id, required this.name, required this.description, required this.imageUrl, required this.pricePerGuest, this.isAvailable = true, final  List<String> dietaryInfo = const []}): _dietaryInfo = dietaryInfo;
  factory _MenuPackage.fromJson(Map<String, dynamic> json) => _$MenuPackageFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String imageUrl;
@override final  double pricePerGuest;
@override@JsonKey() final  bool isAvailable;
 final  List<String> _dietaryInfo;
@override@JsonKey() List<String> get dietaryInfo {
  if (_dietaryInfo is EqualUnmodifiableListView) return _dietaryInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryInfo);
}


/// Create a copy of MenuPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPackageCopyWith<_MenuPackage> get copyWith => __$MenuPackageCopyWithImpl<_MenuPackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuPackageToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MenuPackage'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('pricePerGuest', pricePerGuest))..add(DiagnosticsProperty('isAvailable', isAvailable))..add(DiagnosticsProperty('dietaryInfo', dietaryInfo));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.pricePerGuest, pricePerGuest) || other.pricePerGuest == pricePerGuest)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&const DeepCollectionEquality().equals(other._dietaryInfo, _dietaryInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,imageUrl,pricePerGuest,isAvailable,const DeepCollectionEquality().hash(_dietaryInfo));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MenuPackage(id: $id, name: $name, description: $description, imageUrl: $imageUrl, pricePerGuest: $pricePerGuest, isAvailable: $isAvailable, dietaryInfo: $dietaryInfo)';
}


}

/// @nodoc
abstract mixin class _$MenuPackageCopyWith<$Res> implements $MenuPackageCopyWith<$Res> {
  factory _$MenuPackageCopyWith(_MenuPackage value, $Res Function(_MenuPackage) _then) = __$MenuPackageCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String imageUrl, double pricePerGuest, bool isAvailable, List<String> dietaryInfo
});




}
/// @nodoc
class __$MenuPackageCopyWithImpl<$Res>
    implements _$MenuPackageCopyWith<$Res> {
  __$MenuPackageCopyWithImpl(this._self, this._then);

  final _MenuPackage _self;
  final $Res Function(_MenuPackage) _then;

/// Create a copy of MenuPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? pricePerGuest = null,Object? isAvailable = null,Object? dietaryInfo = null,}) {
  return _then(_MenuPackage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,pricePerGuest: null == pricePerGuest ? _self.pricePerGuest : pricePerGuest // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,dietaryInfo: null == dietaryInfo ? _self._dietaryInfo : dietaryInfo // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$AppUser implements DiagnosticableTreeMixin {

 String get id; String get email; String? get name; String? get phoneNumber; String get role;// 'admin', 'editor', 'user'
 String get status;// 'active', 'inactive', 'banned'
 DateTime? get lastLogin; String? get avatarUrl;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppUser'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('phoneNumber', phoneNumber))..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('lastLogin', lastLogin))..add(DiagnosticsProperty('avatarUrl', avatarUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,phoneNumber,role,status,lastLogin,avatarUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppUser(id: $id, email: $email, name: $name, phoneNumber: $phoneNumber, role: $role, status: $status, lastLogin: $lastLogin, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? name, String? phoneNumber, String role, String status, DateTime? lastLogin, String? avatarUrl
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = freezed,Object? phoneNumber = freezed,Object? role = null,Object? status = null,Object? lastLogin = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as DateTime?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String? name,  String? phoneNumber,  String role,  String status,  DateTime? lastLogin,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.phoneNumber,_that.role,_that.status,_that.lastLogin,_that.avatarUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String? name,  String? phoneNumber,  String role,  String status,  DateTime? lastLogin,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.email,_that.name,_that.phoneNumber,_that.role,_that.status,_that.lastLogin,_that.avatarUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String? name,  String? phoneNumber,  String role,  String status,  DateTime? lastLogin,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.phoneNumber,_that.role,_that.status,_that.lastLogin,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser with DiagnosticableTreeMixin implements AppUser {
  const _AppUser({required this.id, required this.email, this.name, this.phoneNumber, this.role = 'user', this.status = 'active', this.lastLogin, this.avatarUrl});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String? name;
@override final  String? phoneNumber;
@override@JsonKey() final  String role;
// 'admin', 'editor', 'user'
@override@JsonKey() final  String status;
// 'active', 'inactive', 'banned'
@override final  DateTime? lastLogin;
@override final  String? avatarUrl;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppUser'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('phoneNumber', phoneNumber))..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('lastLogin', lastLogin))..add(DiagnosticsProperty('avatarUrl', avatarUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,phoneNumber,role,status,lastLogin,avatarUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppUser(id: $id, email: $email, name: $name, phoneNumber: $phoneNumber, role: $role, status: $status, lastLogin: $lastLogin, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? name, String? phoneNumber, String role, String status, DateTime? lastLogin, String? avatarUrl
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = freezed,Object? phoneNumber = freezed,Object? role = null,Object? status = null,Object? lastLogin = freezed,Object? avatarUrl = freezed,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as DateTime?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Booking implements DiagnosticableTreeMixin {

 String get id; String get userId; String get menuPackageId; String get menuPackageName; String get packageImageUrl;// Snapshot for history
 DateTime get eventDateTime; int get numberOfGuests; double get basePricePerGuest;// Snapshot of price at booking
 double get serviceCharge; double get totalPrice; String get status;// 'pending', 'confirmed', 'cancelled'
 String? get specialRequests; DateTime get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Booking'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('menuPackageId', menuPackageId))..add(DiagnosticsProperty('menuPackageName', menuPackageName))..add(DiagnosticsProperty('packageImageUrl', packageImageUrl))..add(DiagnosticsProperty('eventDateTime', eventDateTime))..add(DiagnosticsProperty('numberOfGuests', numberOfGuests))..add(DiagnosticsProperty('basePricePerGuest', basePricePerGuest))..add(DiagnosticsProperty('serviceCharge', serviceCharge))..add(DiagnosticsProperty('totalPrice', totalPrice))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('specialRequests', specialRequests))..add(DiagnosticsProperty('createdAt', createdAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.menuPackageId, menuPackageId) || other.menuPackageId == menuPackageId)&&(identical(other.menuPackageName, menuPackageName) || other.menuPackageName == menuPackageName)&&(identical(other.packageImageUrl, packageImageUrl) || other.packageImageUrl == packageImageUrl)&&(identical(other.eventDateTime, eventDateTime) || other.eventDateTime == eventDateTime)&&(identical(other.numberOfGuests, numberOfGuests) || other.numberOfGuests == numberOfGuests)&&(identical(other.basePricePerGuest, basePricePerGuest) || other.basePricePerGuest == basePricePerGuest)&&(identical(other.serviceCharge, serviceCharge) || other.serviceCharge == serviceCharge)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.specialRequests, specialRequests) || other.specialRequests == specialRequests)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,menuPackageId,menuPackageName,packageImageUrl,eventDateTime,numberOfGuests,basePricePerGuest,serviceCharge,totalPrice,status,specialRequests,createdAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Booking(id: $id, userId: $userId, menuPackageId: $menuPackageId, menuPackageName: $menuPackageName, packageImageUrl: $packageImageUrl, eventDateTime: $eventDateTime, numberOfGuests: $numberOfGuests, basePricePerGuest: $basePricePerGuest, serviceCharge: $serviceCharge, totalPrice: $totalPrice, status: $status, specialRequests: $specialRequests, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String menuPackageId, String menuPackageName, String packageImageUrl, DateTime eventDateTime, int numberOfGuests, double basePricePerGuest, double serviceCharge, double totalPrice, String status, String? specialRequests, DateTime createdAt
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? menuPackageId = null,Object? menuPackageName = null,Object? packageImageUrl = null,Object? eventDateTime = null,Object? numberOfGuests = null,Object? basePricePerGuest = null,Object? serviceCharge = null,Object? totalPrice = null,Object? status = null,Object? specialRequests = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,menuPackageId: null == menuPackageId ? _self.menuPackageId : menuPackageId // ignore: cast_nullable_to_non_nullable
as String,menuPackageName: null == menuPackageName ? _self.menuPackageName : menuPackageName // ignore: cast_nullable_to_non_nullable
as String,packageImageUrl: null == packageImageUrl ? _self.packageImageUrl : packageImageUrl // ignore: cast_nullable_to_non_nullable
as String,eventDateTime: null == eventDateTime ? _self.eventDateTime : eventDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,numberOfGuests: null == numberOfGuests ? _self.numberOfGuests : numberOfGuests // ignore: cast_nullable_to_non_nullable
as int,basePricePerGuest: null == basePricePerGuest ? _self.basePricePerGuest : basePricePerGuest // ignore: cast_nullable_to_non_nullable
as double,serviceCharge: null == serviceCharge ? _self.serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,specialRequests: freezed == specialRequests ? _self.specialRequests : specialRequests // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String menuPackageId,  String menuPackageName,  String packageImageUrl,  DateTime eventDateTime,  int numberOfGuests,  double basePricePerGuest,  double serviceCharge,  double totalPrice,  String status,  String? specialRequests,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.menuPackageId,_that.menuPackageName,_that.packageImageUrl,_that.eventDateTime,_that.numberOfGuests,_that.basePricePerGuest,_that.serviceCharge,_that.totalPrice,_that.status,_that.specialRequests,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String menuPackageId,  String menuPackageName,  String packageImageUrl,  DateTime eventDateTime,  int numberOfGuests,  double basePricePerGuest,  double serviceCharge,  double totalPrice,  String status,  String? specialRequests,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.menuPackageId,_that.menuPackageName,_that.packageImageUrl,_that.eventDateTime,_that.numberOfGuests,_that.basePricePerGuest,_that.serviceCharge,_that.totalPrice,_that.status,_that.specialRequests,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String menuPackageId,  String menuPackageName,  String packageImageUrl,  DateTime eventDateTime,  int numberOfGuests,  double basePricePerGuest,  double serviceCharge,  double totalPrice,  String status,  String? specialRequests,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.menuPackageId,_that.menuPackageName,_that.packageImageUrl,_that.eventDateTime,_that.numberOfGuests,_that.basePricePerGuest,_that.serviceCharge,_that.totalPrice,_that.status,_that.specialRequests,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking with DiagnosticableTreeMixin implements Booking {
  const _Booking({required this.id, required this.userId, required this.menuPackageId, required this.menuPackageName, required this.packageImageUrl, required this.eventDateTime, required this.numberOfGuests, required this.basePricePerGuest, required this.serviceCharge, required this.totalPrice, this.status = 'pending', this.specialRequests, required this.createdAt});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String menuPackageId;
@override final  String menuPackageName;
@override final  String packageImageUrl;
// Snapshot for history
@override final  DateTime eventDateTime;
@override final  int numberOfGuests;
@override final  double basePricePerGuest;
// Snapshot of price at booking
@override final  double serviceCharge;
@override final  double totalPrice;
@override@JsonKey() final  String status;
// 'pending', 'confirmed', 'cancelled'
@override final  String? specialRequests;
@override final  DateTime createdAt;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Booking'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('menuPackageId', menuPackageId))..add(DiagnosticsProperty('menuPackageName', menuPackageName))..add(DiagnosticsProperty('packageImageUrl', packageImageUrl))..add(DiagnosticsProperty('eventDateTime', eventDateTime))..add(DiagnosticsProperty('numberOfGuests', numberOfGuests))..add(DiagnosticsProperty('basePricePerGuest', basePricePerGuest))..add(DiagnosticsProperty('serviceCharge', serviceCharge))..add(DiagnosticsProperty('totalPrice', totalPrice))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('specialRequests', specialRequests))..add(DiagnosticsProperty('createdAt', createdAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.menuPackageId, menuPackageId) || other.menuPackageId == menuPackageId)&&(identical(other.menuPackageName, menuPackageName) || other.menuPackageName == menuPackageName)&&(identical(other.packageImageUrl, packageImageUrl) || other.packageImageUrl == packageImageUrl)&&(identical(other.eventDateTime, eventDateTime) || other.eventDateTime == eventDateTime)&&(identical(other.numberOfGuests, numberOfGuests) || other.numberOfGuests == numberOfGuests)&&(identical(other.basePricePerGuest, basePricePerGuest) || other.basePricePerGuest == basePricePerGuest)&&(identical(other.serviceCharge, serviceCharge) || other.serviceCharge == serviceCharge)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.specialRequests, specialRequests) || other.specialRequests == specialRequests)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,menuPackageId,menuPackageName,packageImageUrl,eventDateTime,numberOfGuests,basePricePerGuest,serviceCharge,totalPrice,status,specialRequests,createdAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Booking(id: $id, userId: $userId, menuPackageId: $menuPackageId, menuPackageName: $menuPackageName, packageImageUrl: $packageImageUrl, eventDateTime: $eventDateTime, numberOfGuests: $numberOfGuests, basePricePerGuest: $basePricePerGuest, serviceCharge: $serviceCharge, totalPrice: $totalPrice, status: $status, specialRequests: $specialRequests, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String menuPackageId, String menuPackageName, String packageImageUrl, DateTime eventDateTime, int numberOfGuests, double basePricePerGuest, double serviceCharge, double totalPrice, String status, String? specialRequests, DateTime createdAt
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? menuPackageId = null,Object? menuPackageName = null,Object? packageImageUrl = null,Object? eventDateTime = null,Object? numberOfGuests = null,Object? basePricePerGuest = null,Object? serviceCharge = null,Object? totalPrice = null,Object? status = null,Object? specialRequests = freezed,Object? createdAt = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,menuPackageId: null == menuPackageId ? _self.menuPackageId : menuPackageId // ignore: cast_nullable_to_non_nullable
as String,menuPackageName: null == menuPackageName ? _self.menuPackageName : menuPackageName // ignore: cast_nullable_to_non_nullable
as String,packageImageUrl: null == packageImageUrl ? _self.packageImageUrl : packageImageUrl // ignore: cast_nullable_to_non_nullable
as String,eventDateTime: null == eventDateTime ? _self.eventDateTime : eventDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,numberOfGuests: null == numberOfGuests ? _self.numberOfGuests : numberOfGuests // ignore: cast_nullable_to_non_nullable
as int,basePricePerGuest: null == basePricePerGuest ? _self.basePricePerGuest : basePricePerGuest // ignore: cast_nullable_to_non_nullable
as double,serviceCharge: null == serviceCharge ? _self.serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,specialRequests: freezed == specialRequests ? _self.specialRequests : specialRequests // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
