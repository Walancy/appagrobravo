// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItineraryItemDto {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'titulo') String? get title;// Mapped from 'titulo'
@JsonKey(name: 'nome') String? get oldName;// Backwards compat
@JsonKey(name: 'tipo') String get typeString;@JsonKey(name: 'data') String? get dateString;@JsonKey(name: 'hora_inicio') String? get timeString;@JsonKey(name: 'hora_fim') String? get endTimeString;@JsonKey(name: 'hora_inicio2') DateTime? get startDateTimeOld;@JsonKey(name: 'descricao') String? get description;@JsonKey(name: 'localizacao') String? get location;@JsonKey(name: 'imagem') String? get imageUrl;@JsonKey(name: 'codigo_de') String? get fromCode;@JsonKey(name: 'codigo_para') String? get toCode;@JsonKey(name: 'de') String? get fromCity;@JsonKey(name: 'para') String? get toCity;@JsonKey(name: 'motorista') String? get driverName;@JsonKey(name: 'duracao') String? get durationString;
/// Create a copy of ItineraryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryItemDtoCopyWith<ItineraryItemDto> get copyWith => _$ItineraryItemDtoCopyWithImpl<ItineraryItemDto>(this as ItineraryItemDto, _$identity);

  /// Serializes this ItineraryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.typeString, typeString) || other.typeString == typeString)&&(identical(other.dateString, dateString) || other.dateString == dateString)&&(identical(other.timeString, timeString) || other.timeString == timeString)&&(identical(other.endTimeString, endTimeString) || other.endTimeString == endTimeString)&&(identical(other.startDateTimeOld, startDateTimeOld) || other.startDateTimeOld == startDateTimeOld)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,oldName,typeString,dateString,timeString,endTimeString,startDateTimeOld,description,location,imageUrl,fromCode,toCode,fromCity,toCity,driverName,durationString);

@override
String toString() {
  return 'ItineraryItemDto(id: $id, title: $title, oldName: $oldName, typeString: $typeString, dateString: $dateString, timeString: $timeString, endTimeString: $endTimeString, startDateTimeOld: $startDateTimeOld, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, driverName: $driverName, durationString: $durationString)';
}


}

/// @nodoc
abstract mixin class $ItineraryItemDtoCopyWith<$Res>  {
  factory $ItineraryItemDtoCopyWith(ItineraryItemDto value, $Res Function(ItineraryItemDto) _then) = _$ItineraryItemDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'titulo') String? title,@JsonKey(name: 'nome') String? oldName,@JsonKey(name: 'tipo') String typeString,@JsonKey(name: 'data') String? dateString,@JsonKey(name: 'hora_inicio') String? timeString,@JsonKey(name: 'hora_fim') String? endTimeString,@JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,@JsonKey(name: 'descricao') String? description,@JsonKey(name: 'localizacao') String? location,@JsonKey(name: 'imagem') String? imageUrl,@JsonKey(name: 'codigo_de') String? fromCode,@JsonKey(name: 'codigo_para') String? toCode,@JsonKey(name: 'de') String? fromCity,@JsonKey(name: 'para') String? toCity,@JsonKey(name: 'motorista') String? driverName,@JsonKey(name: 'duracao') String? durationString
});




}
/// @nodoc
class _$ItineraryItemDtoCopyWithImpl<$Res>
    implements $ItineraryItemDtoCopyWith<$Res> {
  _$ItineraryItemDtoCopyWithImpl(this._self, this._then);

  final ItineraryItemDto _self;
  final $Res Function(ItineraryItemDto) _then;

/// Create a copy of ItineraryItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? oldName = freezed,Object? typeString = null,Object? dateString = freezed,Object? timeString = freezed,Object? endTimeString = freezed,Object? startDateTimeOld = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? driverName = freezed,Object? durationString = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,typeString: null == typeString ? _self.typeString : typeString // ignore: cast_nullable_to_non_nullable
as String,dateString: freezed == dateString ? _self.dateString : dateString // ignore: cast_nullable_to_non_nullable
as String?,timeString: freezed == timeString ? _self.timeString : timeString // ignore: cast_nullable_to_non_nullable
as String?,endTimeString: freezed == endTimeString ? _self.endTimeString : endTimeString // ignore: cast_nullable_to_non_nullable
as String?,startDateTimeOld: freezed == startDateTimeOld ? _self.startDateTimeOld : startDateTimeOld // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,fromCode: freezed == fromCode ? _self.fromCode : fromCode // ignore: cast_nullable_to_non_nullable
as String?,toCode: freezed == toCode ? _self.toCode : toCode // ignore: cast_nullable_to_non_nullable
as String?,fromCity: freezed == fromCity ? _self.fromCity : fromCity // ignore: cast_nullable_to_non_nullable
as String?,toCity: freezed == toCity ? _self.toCity : toCity // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryItemDto].
extension ItineraryItemDtoPatterns on ItineraryItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.oldName,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString)  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemDto():
return $default(_that.id,_that.title,_that.oldName,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.oldName,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.driverName,_that.durationString);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryItemDto extends ItineraryItemDto {
  const _ItineraryItemDto({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'titulo') this.title, @JsonKey(name: 'nome') this.oldName, @JsonKey(name: 'tipo') required this.typeString, @JsonKey(name: 'data') this.dateString, @JsonKey(name: 'hora_inicio') this.timeString, @JsonKey(name: 'hora_fim') this.endTimeString, @JsonKey(name: 'hora_inicio2') this.startDateTimeOld, @JsonKey(name: 'descricao') this.description, @JsonKey(name: 'localizacao') this.location, @JsonKey(name: 'imagem') this.imageUrl, @JsonKey(name: 'codigo_de') this.fromCode, @JsonKey(name: 'codigo_para') this.toCode, @JsonKey(name: 'de') this.fromCity, @JsonKey(name: 'para') this.toCity, @JsonKey(name: 'motorista') this.driverName, @JsonKey(name: 'duracao') this.durationString}): super._();
  factory _ItineraryItemDto.fromJson(Map<String, dynamic> json) => _$ItineraryItemDtoFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'titulo') final  String? title;
// Mapped from 'titulo'
@override@JsonKey(name: 'nome') final  String? oldName;
// Backwards compat
@override@JsonKey(name: 'tipo') final  String typeString;
@override@JsonKey(name: 'data') final  String? dateString;
@override@JsonKey(name: 'hora_inicio') final  String? timeString;
@override@JsonKey(name: 'hora_fim') final  String? endTimeString;
@override@JsonKey(name: 'hora_inicio2') final  DateTime? startDateTimeOld;
@override@JsonKey(name: 'descricao') final  String? description;
@override@JsonKey(name: 'localizacao') final  String? location;
@override@JsonKey(name: 'imagem') final  String? imageUrl;
@override@JsonKey(name: 'codigo_de') final  String? fromCode;
@override@JsonKey(name: 'codigo_para') final  String? toCode;
@override@JsonKey(name: 'de') final  String? fromCity;
@override@JsonKey(name: 'para') final  String? toCity;
@override@JsonKey(name: 'motorista') final  String? driverName;
@override@JsonKey(name: 'duracao') final  String? durationString;

/// Create a copy of ItineraryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryItemDtoCopyWith<_ItineraryItemDto> get copyWith => __$ItineraryItemDtoCopyWithImpl<_ItineraryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.typeString, typeString) || other.typeString == typeString)&&(identical(other.dateString, dateString) || other.dateString == dateString)&&(identical(other.timeString, timeString) || other.timeString == timeString)&&(identical(other.endTimeString, endTimeString) || other.endTimeString == endTimeString)&&(identical(other.startDateTimeOld, startDateTimeOld) || other.startDateTimeOld == startDateTimeOld)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,oldName,typeString,dateString,timeString,endTimeString,startDateTimeOld,description,location,imageUrl,fromCode,toCode,fromCity,toCity,driverName,durationString);

@override
String toString() {
  return 'ItineraryItemDto(id: $id, title: $title, oldName: $oldName, typeString: $typeString, dateString: $dateString, timeString: $timeString, endTimeString: $endTimeString, startDateTimeOld: $startDateTimeOld, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, driverName: $driverName, durationString: $durationString)';
}


}

/// @nodoc
abstract mixin class _$ItineraryItemDtoCopyWith<$Res> implements $ItineraryItemDtoCopyWith<$Res> {
  factory _$ItineraryItemDtoCopyWith(_ItineraryItemDto value, $Res Function(_ItineraryItemDto) _then) = __$ItineraryItemDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'titulo') String? title,@JsonKey(name: 'nome') String? oldName,@JsonKey(name: 'tipo') String typeString,@JsonKey(name: 'data') String? dateString,@JsonKey(name: 'hora_inicio') String? timeString,@JsonKey(name: 'hora_fim') String? endTimeString,@JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,@JsonKey(name: 'descricao') String? description,@JsonKey(name: 'localizacao') String? location,@JsonKey(name: 'imagem') String? imageUrl,@JsonKey(name: 'codigo_de') String? fromCode,@JsonKey(name: 'codigo_para') String? toCode,@JsonKey(name: 'de') String? fromCity,@JsonKey(name: 'para') String? toCity,@JsonKey(name: 'motorista') String? driverName,@JsonKey(name: 'duracao') String? durationString
});




}
/// @nodoc
class __$ItineraryItemDtoCopyWithImpl<$Res>
    implements _$ItineraryItemDtoCopyWith<$Res> {
  __$ItineraryItemDtoCopyWithImpl(this._self, this._then);

  final _ItineraryItemDto _self;
  final $Res Function(_ItineraryItemDto) _then;

/// Create a copy of ItineraryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? oldName = freezed,Object? typeString = null,Object? dateString = freezed,Object? timeString = freezed,Object? endTimeString = freezed,Object? startDateTimeOld = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? driverName = freezed,Object? durationString = freezed,}) {
  return _then(_ItineraryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,typeString: null == typeString ? _self.typeString : typeString // ignore: cast_nullable_to_non_nullable
as String,dateString: freezed == dateString ? _self.dateString : dateString // ignore: cast_nullable_to_non_nullable
as String?,timeString: freezed == timeString ? _self.timeString : timeString // ignore: cast_nullable_to_non_nullable
as String?,endTimeString: freezed == endTimeString ? _self.endTimeString : endTimeString // ignore: cast_nullable_to_non_nullable
as String?,startDateTimeOld: freezed == startDateTimeOld ? _self.startDateTimeOld : startDateTimeOld // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,fromCode: freezed == fromCode ? _self.fromCode : fromCode // ignore: cast_nullable_to_non_nullable
as String?,toCode: freezed == toCode ? _self.toCode : toCode // ignore: cast_nullable_to_non_nullable
as String?,fromCity: freezed == fromCity ? _self.fromCity : fromCity // ignore: cast_nullable_to_non_nullable
as String?,toCity: freezed == toCity ? _self.toCity : toCity // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
