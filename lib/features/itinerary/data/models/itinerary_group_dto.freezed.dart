// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_group_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItineraryGroupDto {

 String get id;@JsonKey(name: 'nome') String get name; String? get missionName;@JsonKey(name: 'data_inicio') DateTime get startDate;@JsonKey(name: 'data_fim') DateTime get endDate; String? get status;
/// Create a copy of ItineraryGroupDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryGroupDtoCopyWith<ItineraryGroupDto> get copyWith => _$ItineraryGroupDtoCopyWithImpl<ItineraryGroupDto>(this as ItineraryGroupDto, _$identity);

  /// Serializes this ItineraryGroupDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryGroupDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,missionName,startDate,endDate,status);

@override
String toString() {
  return 'ItineraryGroupDto(id: $id, name: $name, missionName: $missionName, startDate: $startDate, endDate: $endDate, status: $status)';
}


}

/// @nodoc
abstract mixin class $ItineraryGroupDtoCopyWith<$Res>  {
  factory $ItineraryGroupDtoCopyWith(ItineraryGroupDto value, $Res Function(ItineraryGroupDto) _then) = _$ItineraryGroupDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'nome') String name, String? missionName,@JsonKey(name: 'data_inicio') DateTime startDate,@JsonKey(name: 'data_fim') DateTime endDate, String? status
});




}
/// @nodoc
class _$ItineraryGroupDtoCopyWithImpl<$Res>
    implements $ItineraryGroupDtoCopyWith<$Res> {
  _$ItineraryGroupDtoCopyWithImpl(this._self, this._then);

  final ItineraryGroupDto _self;
  final $Res Function(ItineraryGroupDto) _then;

/// Create a copy of ItineraryGroupDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? missionName = freezed,Object? startDate = null,Object? endDate = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryGroupDto].
extension ItineraryGroupDtoPatterns on ItineraryGroupDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryGroupDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryGroupDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryGroupDto value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryGroupDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryGroupDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryGroupDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'nome')  String name,  String? missionName, @JsonKey(name: 'data_inicio')  DateTime startDate, @JsonKey(name: 'data_fim')  DateTime endDate,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryGroupDto() when $default != null:
return $default(_that.id,_that.name,_that.missionName,_that.startDate,_that.endDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'nome')  String name,  String? missionName, @JsonKey(name: 'data_inicio')  DateTime startDate, @JsonKey(name: 'data_fim')  DateTime endDate,  String? status)  $default,) {final _that = this;
switch (_that) {
case _ItineraryGroupDto():
return $default(_that.id,_that.name,_that.missionName,_that.startDate,_that.endDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'nome')  String name,  String? missionName, @JsonKey(name: 'data_inicio')  DateTime startDate, @JsonKey(name: 'data_fim')  DateTime endDate,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryGroupDto() when $default != null:
return $default(_that.id,_that.name,_that.missionName,_that.startDate,_that.endDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryGroupDto extends ItineraryGroupDto {
  const _ItineraryGroupDto({required this.id, @JsonKey(name: 'nome') required this.name, this.missionName, @JsonKey(name: 'data_inicio') required this.startDate, @JsonKey(name: 'data_fim') required this.endDate, this.status}): super._();
  factory _ItineraryGroupDto.fromJson(Map<String, dynamic> json) => _$ItineraryGroupDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'nome') final  String name;
@override final  String? missionName;
@override@JsonKey(name: 'data_inicio') final  DateTime startDate;
@override@JsonKey(name: 'data_fim') final  DateTime endDate;
@override final  String? status;

/// Create a copy of ItineraryGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryGroupDtoCopyWith<_ItineraryGroupDto> get copyWith => __$ItineraryGroupDtoCopyWithImpl<_ItineraryGroupDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryGroupDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryGroupDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,missionName,startDate,endDate,status);

@override
String toString() {
  return 'ItineraryGroupDto(id: $id, name: $name, missionName: $missionName, startDate: $startDate, endDate: $endDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ItineraryGroupDtoCopyWith<$Res> implements $ItineraryGroupDtoCopyWith<$Res> {
  factory _$ItineraryGroupDtoCopyWith(_ItineraryGroupDto value, $Res Function(_ItineraryGroupDto) _then) = __$ItineraryGroupDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'nome') String name, String? missionName,@JsonKey(name: 'data_inicio') DateTime startDate,@JsonKey(name: 'data_fim') DateTime endDate, String? status
});




}
/// @nodoc
class __$ItineraryGroupDtoCopyWithImpl<$Res>
    implements _$ItineraryGroupDtoCopyWith<$Res> {
  __$ItineraryGroupDtoCopyWithImpl(this._self, this._then);

  final _ItineraryGroupDto _self;
  final $Res Function(_ItineraryGroupDto) _then;

/// Create a copy of ItineraryGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? missionName = freezed,Object? startDate = null,Object? endDate = null,Object? status = freezed,}) {
  return _then(_ItineraryGroupDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
