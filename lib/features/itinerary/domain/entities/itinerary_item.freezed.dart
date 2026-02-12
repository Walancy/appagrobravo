// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ItineraryItemEntity {

 String get id; String get name; ItineraryType get type; DateTime? get startDateTime; DateTime? get endDateTime; String? get description; String? get location; String? get imageUrl;// Flight specific
 String? get fromCode; String? get toCode; String? get fromCity; String? get toCity;// Transfer specific
 String? get driverName; String? get durationString; String? get travelTime; List<Map<String, dynamic>>? get connections;
/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryItemEntityCopyWith<ItineraryItemEntity> get copyWith => _$ItineraryItemEntityCopyWithImpl<ItineraryItemEntity>(this as ItineraryItemEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDateTime, startDateTime) || other.startDateTime == startDateTime)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other.connections, connections));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,startDateTime,endDateTime,description,location,imageUrl,fromCode,toCode,fromCity,toCity,driverName,durationString,travelTime,const DeepCollectionEquality().hash(connections));

@override
String toString() {
  return 'ItineraryItemEntity(id: $id, name: $name, type: $type, startDateTime: $startDateTime, endDateTime: $endDateTime, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections)';
}


}

/// @nodoc
abstract mixin class $ItineraryItemEntityCopyWith<$Res>  {
  factory $ItineraryItemEntityCopyWith(ItineraryItemEntity value, $Res Function(ItineraryItemEntity) _then) = _$ItineraryItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, ItineraryType type, DateTime? startDateTime, DateTime? endDateTime, String? description, String? location, String? imageUrl, String? fromCode, String? toCode, String? fromCity, String? toCity, String? driverName, String? durationString, String? travelTime, List<Map<String, dynamic>>? connections
});




}
/// @nodoc
class _$ItineraryItemEntityCopyWithImpl<$Res>
    implements $ItineraryItemEntityCopyWith<$Res> {
  _$ItineraryItemEntityCopyWithImpl(this._self, this._then);

  final ItineraryItemEntity _self;
  final $Res Function(ItineraryItemEntity) _then;

/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? startDateTime = freezed,Object? endDateTime = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItineraryType,startDateTime: freezed == startDateTime ? _self.startDateTime : startDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,fromCode: freezed == fromCode ? _self.fromCode : fromCode // ignore: cast_nullable_to_non_nullable
as String?,toCode: freezed == toCode ? _self.toCode : toCode // ignore: cast_nullable_to_non_nullable
as String?,fromCity: freezed == fromCity ? _self.fromCity : fromCity // ignore: cast_nullable_to_non_nullable
as String?,toCity: freezed == toCity ? _self.toCity : toCity // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,travelTime: freezed == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String?,connections: freezed == connections ? _self.connections : connections // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryItemEntity].
extension ItineraryItemEntityPatterns on ItineraryItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString,_that.travelTime,_that.connections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections)  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemEntity():
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString,_that.travelTime,_that.connections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString,_that.travelTime,_that.connections);case _:
  return null;

}
}

}

/// @nodoc


class _ItineraryItemEntity extends ItineraryItemEntity {
  const _ItineraryItemEntity({required this.id, required this.name, required this.type, this.startDateTime, this.endDateTime, this.description, this.location, this.imageUrl, this.fromCode, this.toCode, this.fromCity, this.toCity, this.driverName, this.durationString, this.travelTime, final  List<Map<String, dynamic>>? connections}): _connections = connections,super._();
  

@override final  String id;
@override final  String name;
@override final  ItineraryType type;
@override final  DateTime? startDateTime;
@override final  DateTime? endDateTime;
@override final  String? description;
@override final  String? location;
@override final  String? imageUrl;
// Flight specific
@override final  String? fromCode;
@override final  String? toCode;
@override final  String? fromCity;
@override final  String? toCity;
// Transfer specific
@override final  String? driverName;
@override final  String? durationString;
@override final  String? travelTime;
 final  List<Map<String, dynamic>>? _connections;
@override List<Map<String, dynamic>>? get connections {
  final value = _connections;
  if (value == null) return null;
  if (_connections is EqualUnmodifiableListView) return _connections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryItemEntityCopyWith<_ItineraryItemEntity> get copyWith => __$ItineraryItemEntityCopyWithImpl<_ItineraryItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDateTime, startDateTime) || other.startDateTime == startDateTime)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other._connections, _connections));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,startDateTime,endDateTime,description,location,imageUrl,fromCode,toCode,fromCity,toCity,driverName,durationString,travelTime,const DeepCollectionEquality().hash(_connections));

@override
String toString() {
  return 'ItineraryItemEntity(id: $id, name: $name, type: $type, startDateTime: $startDateTime, endDateTime: $endDateTime, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections)';
}


}

/// @nodoc
abstract mixin class _$ItineraryItemEntityCopyWith<$Res> implements $ItineraryItemEntityCopyWith<$Res> {
  factory _$ItineraryItemEntityCopyWith(_ItineraryItemEntity value, $Res Function(_ItineraryItemEntity) _then) = __$ItineraryItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ItineraryType type, DateTime? startDateTime, DateTime? endDateTime, String? description, String? location, String? imageUrl, String? fromCode, String? toCode, String? fromCity, String? toCity, String? driverName, String? durationString, String? travelTime, List<Map<String, dynamic>>? connections
});




}
/// @nodoc
class __$ItineraryItemEntityCopyWithImpl<$Res>
    implements _$ItineraryItemEntityCopyWith<$Res> {
  __$ItineraryItemEntityCopyWithImpl(this._self, this._then);

  final _ItineraryItemEntity _self;
  final $Res Function(_ItineraryItemEntity) _then;

/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? startDateTime = freezed,Object? endDateTime = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,}) {
  return _then(_ItineraryItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItineraryType,startDateTime: freezed == startDateTime ? _self.startDateTime : startDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,fromCode: freezed == fromCode ? _self.fromCode : fromCode // ignore: cast_nullable_to_non_nullable
as String?,toCode: freezed == toCode ? _self.toCode : toCode // ignore: cast_nullable_to_non_nullable
as String?,fromCity: freezed == fromCity ? _self.fromCity : fromCity // ignore: cast_nullable_to_non_nullable
as String?,toCity: freezed == toCity ? _self.toCity : toCity // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,travelTime: freezed == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String?,connections: freezed == connections ? _self._connections : connections // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}


}

// dart format on
