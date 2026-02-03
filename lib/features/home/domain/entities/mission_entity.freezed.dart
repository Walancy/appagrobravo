// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionEntity {

 String get id; String get name; String? get logo;
/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionEntityCopyWith<MissionEntity> get copyWith => _$MissionEntityCopyWithImpl<MissionEntity>(this as MissionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logo);

@override
String toString() {
  return 'MissionEntity(id: $id, name: $name, logo: $logo)';
}


}

/// @nodoc
abstract mixin class $MissionEntityCopyWith<$Res>  {
  factory $MissionEntityCopyWith(MissionEntity value, $Res Function(MissionEntity) _then) = _$MissionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? logo
});




}
/// @nodoc
class _$MissionEntityCopyWithImpl<$Res>
    implements $MissionEntityCopyWith<$Res> {
  _$MissionEntityCopyWithImpl(this._self, this._then);

  final MissionEntity _self;
  final $Res Function(MissionEntity) _then;

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MissionEntity].
extension MissionEntityPatterns on MissionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionEntity value)  $default,){
final _that = this;
switch (_that) {
case _MissionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? logo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
return $default(_that.id,_that.name,_that.logo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? logo)  $default,) {final _that = this;
switch (_that) {
case _MissionEntity():
return $default(_that.id,_that.name,_that.logo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? logo)?  $default,) {final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
return $default(_that.id,_that.name,_that.logo);case _:
  return null;

}
}

}

/// @nodoc


class _MissionEntity extends MissionEntity {
  const _MissionEntity({required this.id, required this.name, this.logo}): super._();
  

@override final  String id;
@override final  String name;
@override final  String? logo;

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionEntityCopyWith<_MissionEntity> get copyWith => __$MissionEntityCopyWithImpl<_MissionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,logo);

@override
String toString() {
  return 'MissionEntity(id: $id, name: $name, logo: $logo)';
}


}

/// @nodoc
abstract mixin class _$MissionEntityCopyWith<$Res> implements $MissionEntityCopyWith<$Res> {
  factory _$MissionEntityCopyWith(_MissionEntity value, $Res Function(_MissionEntity) _then) = __$MissionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? logo
});




}
/// @nodoc
class __$MissionEntityCopyWithImpl<$Res>
    implements _$MissionEntityCopyWith<$Res> {
  __$MissionEntityCopyWithImpl(this._self, this._then);

  final _MissionEntity _self;
  final $Res Function(_MissionEntity) _then;

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logo = freezed,}) {
  return _then(_MissionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
