// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItineraryGroupEntity {

 String get id; String get name; DateTime get startDate; DateTime get endDate;
/// Create a copy of ItineraryGroupEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryGroupEntityCopyWith<ItineraryGroupEntity> get copyWith => _$ItineraryGroupEntityCopyWithImpl<ItineraryGroupEntity>(this as ItineraryGroupEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate);

@override
String toString() {
  return 'ItineraryGroupEntity(id: $id, name: $name, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $ItineraryGroupEntityCopyWith<$Res>  {
  factory $ItineraryGroupEntityCopyWith(ItineraryGroupEntity value, $Res Function(ItineraryGroupEntity) _then) = _$ItineraryGroupEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class _$ItineraryGroupEntityCopyWithImpl<$Res>
    implements $ItineraryGroupEntityCopyWith<$Res> {
  _$ItineraryGroupEntityCopyWithImpl(this._self, this._then);

  final ItineraryGroupEntity _self;
  final $Res Function(ItineraryGroupEntity) _then;

/// Create a copy of ItineraryGroupEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryGroupEntity].
extension ItineraryGroupEntityPatterns on ItineraryGroupEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryGroupEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryGroupEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryGroupEntity value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryGroupEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryGroupEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryGroupEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryGroupEntity() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate)  $default,) {final _that = this;
switch (_that) {
case _ItineraryGroupEntity():
return $default(_that.id,_that.name,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime startDate,  DateTime endDate)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryGroupEntity() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _ItineraryGroupEntity extends ItineraryGroupEntity {
  const _ItineraryGroupEntity({required this.id, required this.name, required this.startDate, required this.endDate}): super._();
  

@override final  String id;
@override final  String name;
@override final  DateTime startDate;
@override final  DateTime endDate;

/// Create a copy of ItineraryGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryGroupEntityCopyWith<_ItineraryGroupEntity> get copyWith => __$ItineraryGroupEntityCopyWithImpl<_ItineraryGroupEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate);

@override
String toString() {
  return 'ItineraryGroupEntity(id: $id, name: $name, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$ItineraryGroupEntityCopyWith<$Res> implements $ItineraryGroupEntityCopyWith<$Res> {
  factory _$ItineraryGroupEntityCopyWith(_ItineraryGroupEntity value, $Res Function(_ItineraryGroupEntity) _then) = __$ItineraryGroupEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$ItineraryGroupEntityCopyWithImpl<$Res>
    implements _$ItineraryGroupEntityCopyWith<$Res> {
  __$ItineraryGroupEntityCopyWithImpl(this._self, this._then);

  final _ItineraryGroupEntity _self;
  final $Res Function(_ItineraryGroupEntity) _then;

/// Create a copy of ItineraryGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_ItineraryGroupEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
