// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileEntity {

 String get id; String get name; String? get avatarUrl; String? get coverUrl; String? get jobTitle; String? get company; String? get bio; String? get missionName; String? get groupName; String? get email; String? get phone; String? get cpf; String? get ssn; String? get zipCode; String? get state; String? get city; String? get street; String? get number; String? get neighborhood; String? get complement; DateTime? get birthDate; String? get nationality; String? get passport; List<String>? get foodPreferences; List<String>? get medicalRestrictions; int get connectionsCount; int get postsCount; int get missionsCount; ConnectionStatus get connectionStatus;
/// Create a copy of ProfileEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileEntityCopyWith<ProfileEntity> get copyWith => _$ProfileEntityCopyWithImpl<ProfileEntity>(this as ProfileEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.company, company) || other.company == company)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.passport, passport) || other.passport == passport)&&const DeepCollectionEquality().equals(other.foodPreferences, foodPreferences)&&const DeepCollectionEquality().equals(other.medicalRestrictions, medicalRestrictions)&&(identical(other.connectionsCount, connectionsCount) || other.connectionsCount == connectionsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.missionsCount, missionsCount) || other.missionsCount == missionsCount)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,avatarUrl,coverUrl,jobTitle,company,bio,missionName,groupName,email,phone,cpf,ssn,zipCode,state,city,street,number,neighborhood,complement,birthDate,nationality,passport,const DeepCollectionEquality().hash(foodPreferences),const DeepCollectionEquality().hash(medicalRestrictions),connectionsCount,postsCount,missionsCount,connectionStatus]);

@override
String toString() {
  return 'ProfileEntity(id: $id, name: $name, avatarUrl: $avatarUrl, coverUrl: $coverUrl, jobTitle: $jobTitle, company: $company, bio: $bio, missionName: $missionName, groupName: $groupName, email: $email, phone: $phone, cpf: $cpf, ssn: $ssn, zipCode: $zipCode, state: $state, city: $city, street: $street, number: $number, neighborhood: $neighborhood, complement: $complement, birthDate: $birthDate, nationality: $nationality, passport: $passport, foodPreferences: $foodPreferences, medicalRestrictions: $medicalRestrictions, connectionsCount: $connectionsCount, postsCount: $postsCount, missionsCount: $missionsCount, connectionStatus: $connectionStatus)';
}


}

/// @nodoc
abstract mixin class $ProfileEntityCopyWith<$Res>  {
  factory $ProfileEntityCopyWith(ProfileEntity value, $Res Function(ProfileEntity) _then) = _$ProfileEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatarUrl, String? coverUrl, String? jobTitle, String? company, String? bio, String? missionName, String? groupName, String? email, String? phone, String? cpf, String? ssn, String? zipCode, String? state, String? city, String? street, String? number, String? neighborhood, String? complement, DateTime? birthDate, String? nationality, String? passport, List<String>? foodPreferences, List<String>? medicalRestrictions, int connectionsCount, int postsCount, int missionsCount, ConnectionStatus connectionStatus
});




}
/// @nodoc
class _$ProfileEntityCopyWithImpl<$Res>
    implements $ProfileEntityCopyWith<$Res> {
  _$ProfileEntityCopyWithImpl(this._self, this._then);

  final ProfileEntity _self;
  final $Res Function(ProfileEntity) _then;

/// Create a copy of ProfileEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? coverUrl = freezed,Object? jobTitle = freezed,Object? company = freezed,Object? bio = freezed,Object? missionName = freezed,Object? groupName = freezed,Object? email = freezed,Object? phone = freezed,Object? cpf = freezed,Object? ssn = freezed,Object? zipCode = freezed,Object? state = freezed,Object? city = freezed,Object? street = freezed,Object? number = freezed,Object? neighborhood = freezed,Object? complement = freezed,Object? birthDate = freezed,Object? nationality = freezed,Object? passport = freezed,Object? foodPreferences = freezed,Object? medicalRestrictions = freezed,Object? connectionsCount = null,Object? postsCount = null,Object? missionsCount = null,Object? connectionStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,ssn: freezed == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,passport: freezed == passport ? _self.passport : passport // ignore: cast_nullable_to_non_nullable
as String?,foodPreferences: freezed == foodPreferences ? _self.foodPreferences : foodPreferences // ignore: cast_nullable_to_non_nullable
as List<String>?,medicalRestrictions: freezed == medicalRestrictions ? _self.medicalRestrictions : medicalRestrictions // ignore: cast_nullable_to_non_nullable
as List<String>?,connectionsCount: null == connectionsCount ? _self.connectionsCount : connectionsCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,missionsCount: null == missionsCount ? _self.missionsCount : missionsCount // ignore: cast_nullable_to_non_nullable
as int,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileEntity].
extension ProfileEntityPatterns on ProfileEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  String? coverUrl,  String? jobTitle,  String? company,  String? bio,  String? missionName,  String? groupName,  String? email,  String? phone,  String? cpf,  String? ssn,  String? zipCode,  String? state,  String? city,  String? street,  String? number,  String? neighborhood,  String? complement,  DateTime? birthDate,  String? nationality,  String? passport,  List<String>? foodPreferences,  List<String>? medicalRestrictions,  int connectionsCount,  int postsCount,  int missionsCount,  ConnectionStatus connectionStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileEntity() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.coverUrl,_that.jobTitle,_that.company,_that.bio,_that.missionName,_that.groupName,_that.email,_that.phone,_that.cpf,_that.ssn,_that.zipCode,_that.state,_that.city,_that.street,_that.number,_that.neighborhood,_that.complement,_that.birthDate,_that.nationality,_that.passport,_that.foodPreferences,_that.medicalRestrictions,_that.connectionsCount,_that.postsCount,_that.missionsCount,_that.connectionStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatarUrl,  String? coverUrl,  String? jobTitle,  String? company,  String? bio,  String? missionName,  String? groupName,  String? email,  String? phone,  String? cpf,  String? ssn,  String? zipCode,  String? state,  String? city,  String? street,  String? number,  String? neighborhood,  String? complement,  DateTime? birthDate,  String? nationality,  String? passport,  List<String>? foodPreferences,  List<String>? medicalRestrictions,  int connectionsCount,  int postsCount,  int missionsCount,  ConnectionStatus connectionStatus)  $default,) {final _that = this;
switch (_that) {
case _ProfileEntity():
return $default(_that.id,_that.name,_that.avatarUrl,_that.coverUrl,_that.jobTitle,_that.company,_that.bio,_that.missionName,_that.groupName,_that.email,_that.phone,_that.cpf,_that.ssn,_that.zipCode,_that.state,_that.city,_that.street,_that.number,_that.neighborhood,_that.complement,_that.birthDate,_that.nationality,_that.passport,_that.foodPreferences,_that.medicalRestrictions,_that.connectionsCount,_that.postsCount,_that.missionsCount,_that.connectionStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatarUrl,  String? coverUrl,  String? jobTitle,  String? company,  String? bio,  String? missionName,  String? groupName,  String? email,  String? phone,  String? cpf,  String? ssn,  String? zipCode,  String? state,  String? city,  String? street,  String? number,  String? neighborhood,  String? complement,  DateTime? birthDate,  String? nationality,  String? passport,  List<String>? foodPreferences,  List<String>? medicalRestrictions,  int connectionsCount,  int postsCount,  int missionsCount,  ConnectionStatus connectionStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProfileEntity() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.coverUrl,_that.jobTitle,_that.company,_that.bio,_that.missionName,_that.groupName,_that.email,_that.phone,_that.cpf,_that.ssn,_that.zipCode,_that.state,_that.city,_that.street,_that.number,_that.neighborhood,_that.complement,_that.birthDate,_that.nationality,_that.passport,_that.foodPreferences,_that.medicalRestrictions,_that.connectionsCount,_that.postsCount,_that.missionsCount,_that.connectionStatus);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileEntity extends ProfileEntity {
  const _ProfileEntity({required this.id, required this.name, required this.avatarUrl, required this.coverUrl, required this.jobTitle, required this.company, required this.bio, required this.missionName, required this.groupName, required this.email, required this.phone, required this.cpf, required this.ssn, required this.zipCode, required this.state, required this.city, required this.street, required this.number, required this.neighborhood, required this.complement, required this.birthDate, required this.nationality, required this.passport, required final  List<String>? foodPreferences, required final  List<String>? medicalRestrictions, required this.connectionsCount, required this.postsCount, required this.missionsCount, this.connectionStatus = ConnectionStatus.none}): _foodPreferences = foodPreferences,_medicalRestrictions = medicalRestrictions,super._();
  

@override final  String id;
@override final  String name;
@override final  String? avatarUrl;
@override final  String? coverUrl;
@override final  String? jobTitle;
@override final  String? company;
@override final  String? bio;
@override final  String? missionName;
@override final  String? groupName;
@override final  String? email;
@override final  String? phone;
@override final  String? cpf;
@override final  String? ssn;
@override final  String? zipCode;
@override final  String? state;
@override final  String? city;
@override final  String? street;
@override final  String? number;
@override final  String? neighborhood;
@override final  String? complement;
@override final  DateTime? birthDate;
@override final  String? nationality;
@override final  String? passport;
 final  List<String>? _foodPreferences;
@override List<String>? get foodPreferences {
  final value = _foodPreferences;
  if (value == null) return null;
  if (_foodPreferences is EqualUnmodifiableListView) return _foodPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _medicalRestrictions;
@override List<String>? get medicalRestrictions {
  final value = _medicalRestrictions;
  if (value == null) return null;
  if (_medicalRestrictions is EqualUnmodifiableListView) return _medicalRestrictions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int connectionsCount;
@override final  int postsCount;
@override final  int missionsCount;
@override@JsonKey() final  ConnectionStatus connectionStatus;

/// Create a copy of ProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileEntityCopyWith<_ProfileEntity> get copyWith => __$ProfileEntityCopyWithImpl<_ProfileEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.company, company) || other.company == company)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.passport, passport) || other.passport == passport)&&const DeepCollectionEquality().equals(other._foodPreferences, _foodPreferences)&&const DeepCollectionEquality().equals(other._medicalRestrictions, _medicalRestrictions)&&(identical(other.connectionsCount, connectionsCount) || other.connectionsCount == connectionsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.missionsCount, missionsCount) || other.missionsCount == missionsCount)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,avatarUrl,coverUrl,jobTitle,company,bio,missionName,groupName,email,phone,cpf,ssn,zipCode,state,city,street,number,neighborhood,complement,birthDate,nationality,passport,const DeepCollectionEquality().hash(_foodPreferences),const DeepCollectionEquality().hash(_medicalRestrictions),connectionsCount,postsCount,missionsCount,connectionStatus]);

@override
String toString() {
  return 'ProfileEntity(id: $id, name: $name, avatarUrl: $avatarUrl, coverUrl: $coverUrl, jobTitle: $jobTitle, company: $company, bio: $bio, missionName: $missionName, groupName: $groupName, email: $email, phone: $phone, cpf: $cpf, ssn: $ssn, zipCode: $zipCode, state: $state, city: $city, street: $street, number: $number, neighborhood: $neighborhood, complement: $complement, birthDate: $birthDate, nationality: $nationality, passport: $passport, foodPreferences: $foodPreferences, medicalRestrictions: $medicalRestrictions, connectionsCount: $connectionsCount, postsCount: $postsCount, missionsCount: $missionsCount, connectionStatus: $connectionStatus)';
}


}

/// @nodoc
abstract mixin class _$ProfileEntityCopyWith<$Res> implements $ProfileEntityCopyWith<$Res> {
  factory _$ProfileEntityCopyWith(_ProfileEntity value, $Res Function(_ProfileEntity) _then) = __$ProfileEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatarUrl, String? coverUrl, String? jobTitle, String? company, String? bio, String? missionName, String? groupName, String? email, String? phone, String? cpf, String? ssn, String? zipCode, String? state, String? city, String? street, String? number, String? neighborhood, String? complement, DateTime? birthDate, String? nationality, String? passport, List<String>? foodPreferences, List<String>? medicalRestrictions, int connectionsCount, int postsCount, int missionsCount, ConnectionStatus connectionStatus
});




}
/// @nodoc
class __$ProfileEntityCopyWithImpl<$Res>
    implements _$ProfileEntityCopyWith<$Res> {
  __$ProfileEntityCopyWithImpl(this._self, this._then);

  final _ProfileEntity _self;
  final $Res Function(_ProfileEntity) _then;

/// Create a copy of ProfileEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? coverUrl = freezed,Object? jobTitle = freezed,Object? company = freezed,Object? bio = freezed,Object? missionName = freezed,Object? groupName = freezed,Object? email = freezed,Object? phone = freezed,Object? cpf = freezed,Object? ssn = freezed,Object? zipCode = freezed,Object? state = freezed,Object? city = freezed,Object? street = freezed,Object? number = freezed,Object? neighborhood = freezed,Object? complement = freezed,Object? birthDate = freezed,Object? nationality = freezed,Object? passport = freezed,Object? foodPreferences = freezed,Object? medicalRestrictions = freezed,Object? connectionsCount = null,Object? postsCount = null,Object? missionsCount = null,Object? connectionStatus = null,}) {
  return _then(_ProfileEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,cpf: freezed == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String?,ssn: freezed == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: freezed == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String?,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,passport: freezed == passport ? _self.passport : passport // ignore: cast_nullable_to_non_nullable
as String?,foodPreferences: freezed == foodPreferences ? _self._foodPreferences : foodPreferences // ignore: cast_nullable_to_non_nullable
as List<String>?,medicalRestrictions: freezed == medicalRestrictions ? _self._medicalRestrictions : medicalRestrictions // ignore: cast_nullable_to_non_nullable
as List<String>?,connectionsCount: null == connectionsCount ? _self.connectionsCount : connectionsCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,missionsCount: null == missionsCount ? _self.missionsCount : missionsCount // ignore: cast_nullable_to_non_nullable
as int,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,
  ));
}


}

// dart format on
