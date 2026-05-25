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

@JsonKey(name: 'id') String get id;@JsonKey(name: 'titulo') String? get title;@JsonKey(name: 'nome') String? get oldName;@JsonKey(name: 'subtitulo') String? get subtitle;@JsonKey(name: 'tipo') String get typeString;@JsonKey(name: 'data') String? get dateString;@JsonKey(name: 'hora_inicio') String? get timeString;@JsonKey(name: 'hora_fim') String? get endTimeString;@JsonKey(name: 'hora_inicio2') DateTime? get startDateTimeOld;@JsonKey(name: 'descricao') String? get description;@JsonKey(name: 'localizacao') String? get location;@JsonKey(name: 'imagem') String? get imageUrl;// Flight route codes
@JsonKey(name: 'codigo_de') String? get fromCode;@JsonKey(name: 'codigo_para') String? get toCode;@JsonKey(name: 'de') String? get fromCity;@JsonKey(name: 'para') String? get toCity;@JsonKey(name: 'hora_de') String? get fromTime;@JsonKey(name: 'hora_para') String? get toTime;@JsonKey(name: 'atrasado') bool? get isDelayed;@JsonKey(name: 'atraso') String? get delay;// Transfer
@JsonKey(name: 'motorista') String? get driverName;@JsonKey(name: 'duracao') String? get durationString;@JsonKey(name: 'tempo_deslocamento') String? get travelTime;@JsonKey(name: 'conexoes') List<Map<String, dynamic>>? get connections;@JsonKey(name: 'escalas') List<Map<String, dynamic>>? get escalas;// Enriched location
@JsonKey(name: 'endereco') String? get address;@JsonKey(name: 'cidade') String? get city;@JsonKey(name: 'estado') String? get state;@JsonKey(name: 'pais') String? get country;@JsonKey(name: 'latitude') double? get latitude;@JsonKey(name: 'longitude') double? get longitude;@JsonKey(name: 'rating') double? get rating;@JsonKey(name: 'estrelas') double? get estrelas;@JsonKey(name: 'telefone') String? get telefone;@JsonKey(name: 'website') String? get website;@JsonKey(name: 'imagens') List<String>? get images;@JsonKey(name: 'link_maps') String? get linkMaps;@JsonKey(name: 'evento_referencia_id') String? get eventoReferenciaId;@JsonKey(name: 'is_day_after_transfer') bool? get isDayAfterTransfer;@JsonKey(name: 'dados') Map<String, dynamic>? get dados;// Booking
@JsonKey(name: 'preco') String? get price;@JsonKey(name: 'site_url') String? get siteUrl;@JsonKey(name: 'status') String? get bookingStatus;
/// Create a copy of ItineraryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryItemDtoCopyWith<ItineraryItemDto> get copyWith => _$ItineraryItemDtoCopyWithImpl<ItineraryItemDto>(this as ItineraryItemDto, _$identity);

  /// Serializes this ItineraryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.typeString, typeString) || other.typeString == typeString)&&(identical(other.dateString, dateString) || other.dateString == dateString)&&(identical(other.timeString, timeString) || other.timeString == timeString)&&(identical(other.endTimeString, endTimeString) || other.endTimeString == endTimeString)&&(identical(other.startDateTimeOld, startDateTimeOld) || other.startDateTimeOld == startDateTimeOld)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.isDelayed, isDelayed) || other.isDelayed == isDelayed)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other.connections, connections)&&const DeepCollectionEquality().equals(other.escalas, escalas)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.estrelas, estrelas) || other.estrelas == estrelas)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.linkMaps, linkMaps) || other.linkMaps == linkMaps)&&(identical(other.eventoReferenciaId, eventoReferenciaId) || other.eventoReferenciaId == eventoReferenciaId)&&(identical(other.isDayAfterTransfer, isDayAfterTransfer) || other.isDayAfterTransfer == isDayAfterTransfer)&&const DeepCollectionEquality().equals(other.dados, dados)&&(identical(other.price, price) || other.price == price)&&(identical(other.siteUrl, siteUrl) || other.siteUrl == siteUrl)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,oldName,subtitle,typeString,dateString,timeString,endTimeString,startDateTimeOld,description,location,imageUrl,fromCode,toCode,fromCity,toCity,fromTime,toTime,isDelayed,delay,driverName,durationString,travelTime,const DeepCollectionEquality().hash(connections),const DeepCollectionEquality().hash(escalas),address,city,state,country,latitude,longitude,rating,estrelas,telefone,website,const DeepCollectionEquality().hash(images),linkMaps,eventoReferenciaId,isDayAfterTransfer,const DeepCollectionEquality().hash(dados),price,siteUrl,bookingStatus]);

@override
String toString() {
  return 'ItineraryItemDto(id: $id, title: $title, oldName: $oldName, subtitle: $subtitle, typeString: $typeString, dateString: $dateString, timeString: $timeString, endTimeString: $endTimeString, startDateTimeOld: $startDateTimeOld, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, fromTime: $fromTime, toTime: $toTime, isDelayed: $isDelayed, delay: $delay, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections, escalas: $escalas, address: $address, city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude, rating: $rating, estrelas: $estrelas, telefone: $telefone, website: $website, images: $images, linkMaps: $linkMaps, eventoReferenciaId: $eventoReferenciaId, isDayAfterTransfer: $isDayAfterTransfer, dados: $dados, price: $price, siteUrl: $siteUrl, bookingStatus: $bookingStatus)';
}


}

/// @nodoc
abstract mixin class $ItineraryItemDtoCopyWith<$Res>  {
  factory $ItineraryItemDtoCopyWith(ItineraryItemDto value, $Res Function(ItineraryItemDto) _then) = _$ItineraryItemDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'titulo') String? title,@JsonKey(name: 'nome') String? oldName,@JsonKey(name: 'subtitulo') String? subtitle,@JsonKey(name: 'tipo') String typeString,@JsonKey(name: 'data') String? dateString,@JsonKey(name: 'hora_inicio') String? timeString,@JsonKey(name: 'hora_fim') String? endTimeString,@JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,@JsonKey(name: 'descricao') String? description,@JsonKey(name: 'localizacao') String? location,@JsonKey(name: 'imagem') String? imageUrl,@JsonKey(name: 'codigo_de') String? fromCode,@JsonKey(name: 'codigo_para') String? toCode,@JsonKey(name: 'de') String? fromCity,@JsonKey(name: 'para') String? toCity,@JsonKey(name: 'hora_de') String? fromTime,@JsonKey(name: 'hora_para') String? toTime,@JsonKey(name: 'atrasado') bool? isDelayed,@JsonKey(name: 'atraso') String? delay,@JsonKey(name: 'motorista') String? driverName,@JsonKey(name: 'duracao') String? durationString,@JsonKey(name: 'tempo_deslocamento') String? travelTime,@JsonKey(name: 'conexoes') List<Map<String, dynamic>>? connections,@JsonKey(name: 'escalas') List<Map<String, dynamic>>? escalas,@JsonKey(name: 'endereco') String? address,@JsonKey(name: 'cidade') String? city,@JsonKey(name: 'estado') String? state,@JsonKey(name: 'pais') String? country,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'rating') double? rating,@JsonKey(name: 'estrelas') double? estrelas,@JsonKey(name: 'telefone') String? telefone,@JsonKey(name: 'website') String? website,@JsonKey(name: 'imagens') List<String>? images,@JsonKey(name: 'link_maps') String? linkMaps,@JsonKey(name: 'evento_referencia_id') String? eventoReferenciaId,@JsonKey(name: 'is_day_after_transfer') bool? isDayAfterTransfer,@JsonKey(name: 'dados') Map<String, dynamic>? dados,@JsonKey(name: 'preco') String? price,@JsonKey(name: 'site_url') String? siteUrl,@JsonKey(name: 'status') String? bookingStatus
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? oldName = freezed,Object? subtitle = freezed,Object? typeString = null,Object? dateString = freezed,Object? timeString = freezed,Object? endTimeString = freezed,Object? startDateTimeOld = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? isDelayed = freezed,Object? delay = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,Object? escalas = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? rating = freezed,Object? estrelas = freezed,Object? telefone = freezed,Object? website = freezed,Object? images = freezed,Object? linkMaps = freezed,Object? eventoReferenciaId = freezed,Object? isDayAfterTransfer = freezed,Object? dados = freezed,Object? price = freezed,Object? siteUrl = freezed,Object? bookingStatus = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
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
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,isDelayed: freezed == isDelayed ? _self.isDelayed : isDelayed // ignore: cast_nullable_to_non_nullable
as bool?,delay: freezed == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,travelTime: freezed == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String?,connections: freezed == connections ? _self.connections : connections // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,escalas: freezed == escalas ? _self.escalas : escalas // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,estrelas: freezed == estrelas ? _self.estrelas : estrelas // ignore: cast_nullable_to_non_nullable
as double?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>?,linkMaps: freezed == linkMaps ? _self.linkMaps : linkMaps // ignore: cast_nullable_to_non_nullable
as String?,eventoReferenciaId: freezed == eventoReferenciaId ? _self.eventoReferenciaId : eventoReferenciaId // ignore: cast_nullable_to_non_nullable
as String?,isDayAfterTransfer: freezed == isDayAfterTransfer ? _self.isDayAfterTransfer : isDayAfterTransfer // ignore: cast_nullable_to_non_nullable
as bool?,dados: freezed == dados ? _self.dados : dados // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as String?,bookingStatus: freezed == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'subtitulo')  String? subtitle, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'hora_de')  String? fromTime, @JsonKey(name: 'hora_para')  String? toTime, @JsonKey(name: 'atrasado')  bool? isDelayed, @JsonKey(name: 'atraso')  String? delay, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString, @JsonKey(name: 'tempo_deslocamento')  String? travelTime, @JsonKey(name: 'conexoes')  List<Map<String, dynamic>>? connections, @JsonKey(name: 'escalas')  List<Map<String, dynamic>>? escalas, @JsonKey(name: 'endereco')  String? address, @JsonKey(name: 'cidade')  String? city, @JsonKey(name: 'estado')  String? state, @JsonKey(name: 'pais')  String? country, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'rating')  double? rating, @JsonKey(name: 'estrelas')  double? estrelas, @JsonKey(name: 'telefone')  String? telefone, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'imagens')  List<String>? images, @JsonKey(name: 'link_maps')  String? linkMaps, @JsonKey(name: 'evento_referencia_id')  String? eventoReferenciaId, @JsonKey(name: 'is_day_after_transfer')  bool? isDayAfterTransfer, @JsonKey(name: 'dados')  Map<String, dynamic>? dados, @JsonKey(name: 'preco')  String? price, @JsonKey(name: 'site_url')  String? siteUrl, @JsonKey(name: 'status')  String? bookingStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.oldName,_that.subtitle,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.escalas,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.dados,_that.price,_that.siteUrl,_that.bookingStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'subtitulo')  String? subtitle, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'hora_de')  String? fromTime, @JsonKey(name: 'hora_para')  String? toTime, @JsonKey(name: 'atrasado')  bool? isDelayed, @JsonKey(name: 'atraso')  String? delay, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString, @JsonKey(name: 'tempo_deslocamento')  String? travelTime, @JsonKey(name: 'conexoes')  List<Map<String, dynamic>>? connections, @JsonKey(name: 'escalas')  List<Map<String, dynamic>>? escalas, @JsonKey(name: 'endereco')  String? address, @JsonKey(name: 'cidade')  String? city, @JsonKey(name: 'estado')  String? state, @JsonKey(name: 'pais')  String? country, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'rating')  double? rating, @JsonKey(name: 'estrelas')  double? estrelas, @JsonKey(name: 'telefone')  String? telefone, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'imagens')  List<String>? images, @JsonKey(name: 'link_maps')  String? linkMaps, @JsonKey(name: 'evento_referencia_id')  String? eventoReferenciaId, @JsonKey(name: 'is_day_after_transfer')  bool? isDayAfterTransfer, @JsonKey(name: 'dados')  Map<String, dynamic>? dados, @JsonKey(name: 'preco')  String? price, @JsonKey(name: 'site_url')  String? siteUrl, @JsonKey(name: 'status')  String? bookingStatus)  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemDto():
return $default(_that.id,_that.title,_that.oldName,_that.subtitle,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.escalas,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.dados,_that.price,_that.siteUrl,_that.bookingStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'titulo')  String? title, @JsonKey(name: 'nome')  String? oldName, @JsonKey(name: 'subtitulo')  String? subtitle, @JsonKey(name: 'tipo')  String typeString, @JsonKey(name: 'data')  String? dateString, @JsonKey(name: 'hora_inicio')  String? timeString, @JsonKey(name: 'hora_fim')  String? endTimeString, @JsonKey(name: 'hora_inicio2')  DateTime? startDateTimeOld, @JsonKey(name: 'descricao')  String? description, @JsonKey(name: 'localizacao')  String? location, @JsonKey(name: 'imagem')  String? imageUrl, @JsonKey(name: 'codigo_de')  String? fromCode, @JsonKey(name: 'codigo_para')  String? toCode, @JsonKey(name: 'de')  String? fromCity, @JsonKey(name: 'para')  String? toCity, @JsonKey(name: 'hora_de')  String? fromTime, @JsonKey(name: 'hora_para')  String? toTime, @JsonKey(name: 'atrasado')  bool? isDelayed, @JsonKey(name: 'atraso')  String? delay, @JsonKey(name: 'motorista')  String? driverName, @JsonKey(name: 'duracao')  String? durationString, @JsonKey(name: 'tempo_deslocamento')  String? travelTime, @JsonKey(name: 'conexoes')  List<Map<String, dynamic>>? connections, @JsonKey(name: 'escalas')  List<Map<String, dynamic>>? escalas, @JsonKey(name: 'endereco')  String? address, @JsonKey(name: 'cidade')  String? city, @JsonKey(name: 'estado')  String? state, @JsonKey(name: 'pais')  String? country, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'rating')  double? rating, @JsonKey(name: 'estrelas')  double? estrelas, @JsonKey(name: 'telefone')  String? telefone, @JsonKey(name: 'website')  String? website, @JsonKey(name: 'imagens')  List<String>? images, @JsonKey(name: 'link_maps')  String? linkMaps, @JsonKey(name: 'evento_referencia_id')  String? eventoReferenciaId, @JsonKey(name: 'is_day_after_transfer')  bool? isDayAfterTransfer, @JsonKey(name: 'dados')  Map<String, dynamic>? dados, @JsonKey(name: 'preco')  String? price, @JsonKey(name: 'site_url')  String? siteUrl, @JsonKey(name: 'status')  String? bookingStatus)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemDto() when $default != null:
return $default(_that.id,_that.title,_that.oldName,_that.subtitle,_that.typeString,_that.dateString,_that.timeString,_that.endTimeString,_that.startDateTimeOld,_that.description,_that.location,_that.imageUrl,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.escalas,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.dados,_that.price,_that.siteUrl,_that.bookingStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryItemDto extends ItineraryItemDto {
  const _ItineraryItemDto({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'titulo') this.title, @JsonKey(name: 'nome') this.oldName, @JsonKey(name: 'subtitulo') this.subtitle, @JsonKey(name: 'tipo') required this.typeString, @JsonKey(name: 'data') this.dateString, @JsonKey(name: 'hora_inicio') this.timeString, @JsonKey(name: 'hora_fim') this.endTimeString, @JsonKey(name: 'hora_inicio2') this.startDateTimeOld, @JsonKey(name: 'descricao') this.description, @JsonKey(name: 'localizacao') this.location, @JsonKey(name: 'imagem') this.imageUrl, @JsonKey(name: 'codigo_de') this.fromCode, @JsonKey(name: 'codigo_para') this.toCode, @JsonKey(name: 'de') this.fromCity, @JsonKey(name: 'para') this.toCity, @JsonKey(name: 'hora_de') this.fromTime, @JsonKey(name: 'hora_para') this.toTime, @JsonKey(name: 'atrasado') this.isDelayed, @JsonKey(name: 'atraso') this.delay, @JsonKey(name: 'motorista') this.driverName, @JsonKey(name: 'duracao') this.durationString, @JsonKey(name: 'tempo_deslocamento') this.travelTime, @JsonKey(name: 'conexoes') final  List<Map<String, dynamic>>? connections, @JsonKey(name: 'escalas') final  List<Map<String, dynamic>>? escalas, @JsonKey(name: 'endereco') this.address, @JsonKey(name: 'cidade') this.city, @JsonKey(name: 'estado') this.state, @JsonKey(name: 'pais') this.country, @JsonKey(name: 'latitude') this.latitude, @JsonKey(name: 'longitude') this.longitude, @JsonKey(name: 'rating') this.rating, @JsonKey(name: 'estrelas') this.estrelas, @JsonKey(name: 'telefone') this.telefone, @JsonKey(name: 'website') this.website, @JsonKey(name: 'imagens') final  List<String>? images, @JsonKey(name: 'link_maps') this.linkMaps, @JsonKey(name: 'evento_referencia_id') this.eventoReferenciaId, @JsonKey(name: 'is_day_after_transfer') this.isDayAfterTransfer, @JsonKey(name: 'dados') final  Map<String, dynamic>? dados, @JsonKey(name: 'preco') this.price, @JsonKey(name: 'site_url') this.siteUrl, @JsonKey(name: 'status') this.bookingStatus}): _connections = connections,_escalas = escalas,_images = images,_dados = dados,super._();
  factory _ItineraryItemDto.fromJson(Map<String, dynamic> json) => _$ItineraryItemDtoFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'titulo') final  String? title;
@override@JsonKey(name: 'nome') final  String? oldName;
@override@JsonKey(name: 'subtitulo') final  String? subtitle;
@override@JsonKey(name: 'tipo') final  String typeString;
@override@JsonKey(name: 'data') final  String? dateString;
@override@JsonKey(name: 'hora_inicio') final  String? timeString;
@override@JsonKey(name: 'hora_fim') final  String? endTimeString;
@override@JsonKey(name: 'hora_inicio2') final  DateTime? startDateTimeOld;
@override@JsonKey(name: 'descricao') final  String? description;
@override@JsonKey(name: 'localizacao') final  String? location;
@override@JsonKey(name: 'imagem') final  String? imageUrl;
// Flight route codes
@override@JsonKey(name: 'codigo_de') final  String? fromCode;
@override@JsonKey(name: 'codigo_para') final  String? toCode;
@override@JsonKey(name: 'de') final  String? fromCity;
@override@JsonKey(name: 'para') final  String? toCity;
@override@JsonKey(name: 'hora_de') final  String? fromTime;
@override@JsonKey(name: 'hora_para') final  String? toTime;
@override@JsonKey(name: 'atrasado') final  bool? isDelayed;
@override@JsonKey(name: 'atraso') final  String? delay;
// Transfer
@override@JsonKey(name: 'motorista') final  String? driverName;
@override@JsonKey(name: 'duracao') final  String? durationString;
@override@JsonKey(name: 'tempo_deslocamento') final  String? travelTime;
 final  List<Map<String, dynamic>>? _connections;
@override@JsonKey(name: 'conexoes') List<Map<String, dynamic>>? get connections {
  final value = _connections;
  if (value == null) return null;
  if (_connections is EqualUnmodifiableListView) return _connections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Map<String, dynamic>>? _escalas;
@override@JsonKey(name: 'escalas') List<Map<String, dynamic>>? get escalas {
  final value = _escalas;
  if (value == null) return null;
  if (_escalas is EqualUnmodifiableListView) return _escalas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Enriched location
@override@JsonKey(name: 'endereco') final  String? address;
@override@JsonKey(name: 'cidade') final  String? city;
@override@JsonKey(name: 'estado') final  String? state;
@override@JsonKey(name: 'pais') final  String? country;
@override@JsonKey(name: 'latitude') final  double? latitude;
@override@JsonKey(name: 'longitude') final  double? longitude;
@override@JsonKey(name: 'rating') final  double? rating;
@override@JsonKey(name: 'estrelas') final  double? estrelas;
@override@JsonKey(name: 'telefone') final  String? telefone;
@override@JsonKey(name: 'website') final  String? website;
 final  List<String>? _images;
@override@JsonKey(name: 'imagens') List<String>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'link_maps') final  String? linkMaps;
@override@JsonKey(name: 'evento_referencia_id') final  String? eventoReferenciaId;
@override@JsonKey(name: 'is_day_after_transfer') final  bool? isDayAfterTransfer;
 final  Map<String, dynamic>? _dados;
@override@JsonKey(name: 'dados') Map<String, dynamic>? get dados {
  final value = _dados;
  if (value == null) return null;
  if (_dados is EqualUnmodifiableMapView) return _dados;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Booking
@override@JsonKey(name: 'preco') final  String? price;
@override@JsonKey(name: 'site_url') final  String? siteUrl;
@override@JsonKey(name: 'status') final  String? bookingStatus;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.typeString, typeString) || other.typeString == typeString)&&(identical(other.dateString, dateString) || other.dateString == dateString)&&(identical(other.timeString, timeString) || other.timeString == timeString)&&(identical(other.endTimeString, endTimeString) || other.endTimeString == endTimeString)&&(identical(other.startDateTimeOld, startDateTimeOld) || other.startDateTimeOld == startDateTimeOld)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.isDelayed, isDelayed) || other.isDelayed == isDelayed)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other._connections, _connections)&&const DeepCollectionEquality().equals(other._escalas, _escalas)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.estrelas, estrelas) || other.estrelas == estrelas)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.linkMaps, linkMaps) || other.linkMaps == linkMaps)&&(identical(other.eventoReferenciaId, eventoReferenciaId) || other.eventoReferenciaId == eventoReferenciaId)&&(identical(other.isDayAfterTransfer, isDayAfterTransfer) || other.isDayAfterTransfer == isDayAfterTransfer)&&const DeepCollectionEquality().equals(other._dados, _dados)&&(identical(other.price, price) || other.price == price)&&(identical(other.siteUrl, siteUrl) || other.siteUrl == siteUrl)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,oldName,subtitle,typeString,dateString,timeString,endTimeString,startDateTimeOld,description,location,imageUrl,fromCode,toCode,fromCity,toCity,fromTime,toTime,isDelayed,delay,driverName,durationString,travelTime,const DeepCollectionEquality().hash(_connections),const DeepCollectionEquality().hash(_escalas),address,city,state,country,latitude,longitude,rating,estrelas,telefone,website,const DeepCollectionEquality().hash(_images),linkMaps,eventoReferenciaId,isDayAfterTransfer,const DeepCollectionEquality().hash(_dados),price,siteUrl,bookingStatus]);

@override
String toString() {
  return 'ItineraryItemDto(id: $id, title: $title, oldName: $oldName, subtitle: $subtitle, typeString: $typeString, dateString: $dateString, timeString: $timeString, endTimeString: $endTimeString, startDateTimeOld: $startDateTimeOld, description: $description, location: $location, imageUrl: $imageUrl, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, fromTime: $fromTime, toTime: $toTime, isDelayed: $isDelayed, delay: $delay, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections, escalas: $escalas, address: $address, city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude, rating: $rating, estrelas: $estrelas, telefone: $telefone, website: $website, images: $images, linkMaps: $linkMaps, eventoReferenciaId: $eventoReferenciaId, isDayAfterTransfer: $isDayAfterTransfer, dados: $dados, price: $price, siteUrl: $siteUrl, bookingStatus: $bookingStatus)';
}


}

/// @nodoc
abstract mixin class _$ItineraryItemDtoCopyWith<$Res> implements $ItineraryItemDtoCopyWith<$Res> {
  factory _$ItineraryItemDtoCopyWith(_ItineraryItemDto value, $Res Function(_ItineraryItemDto) _then) = __$ItineraryItemDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'titulo') String? title,@JsonKey(name: 'nome') String? oldName,@JsonKey(name: 'subtitulo') String? subtitle,@JsonKey(name: 'tipo') String typeString,@JsonKey(name: 'data') String? dateString,@JsonKey(name: 'hora_inicio') String? timeString,@JsonKey(name: 'hora_fim') String? endTimeString,@JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,@JsonKey(name: 'descricao') String? description,@JsonKey(name: 'localizacao') String? location,@JsonKey(name: 'imagem') String? imageUrl,@JsonKey(name: 'codigo_de') String? fromCode,@JsonKey(name: 'codigo_para') String? toCode,@JsonKey(name: 'de') String? fromCity,@JsonKey(name: 'para') String? toCity,@JsonKey(name: 'hora_de') String? fromTime,@JsonKey(name: 'hora_para') String? toTime,@JsonKey(name: 'atrasado') bool? isDelayed,@JsonKey(name: 'atraso') String? delay,@JsonKey(name: 'motorista') String? driverName,@JsonKey(name: 'duracao') String? durationString,@JsonKey(name: 'tempo_deslocamento') String? travelTime,@JsonKey(name: 'conexoes') List<Map<String, dynamic>>? connections,@JsonKey(name: 'escalas') List<Map<String, dynamic>>? escalas,@JsonKey(name: 'endereco') String? address,@JsonKey(name: 'cidade') String? city,@JsonKey(name: 'estado') String? state,@JsonKey(name: 'pais') String? country,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'rating') double? rating,@JsonKey(name: 'estrelas') double? estrelas,@JsonKey(name: 'telefone') String? telefone,@JsonKey(name: 'website') String? website,@JsonKey(name: 'imagens') List<String>? images,@JsonKey(name: 'link_maps') String? linkMaps,@JsonKey(name: 'evento_referencia_id') String? eventoReferenciaId,@JsonKey(name: 'is_day_after_transfer') bool? isDayAfterTransfer,@JsonKey(name: 'dados') Map<String, dynamic>? dados,@JsonKey(name: 'preco') String? price,@JsonKey(name: 'site_url') String? siteUrl,@JsonKey(name: 'status') String? bookingStatus
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? oldName = freezed,Object? subtitle = freezed,Object? typeString = null,Object? dateString = freezed,Object? timeString = freezed,Object? endTimeString = freezed,Object? startDateTimeOld = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? isDelayed = freezed,Object? delay = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,Object? escalas = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? rating = freezed,Object? estrelas = freezed,Object? telefone = freezed,Object? website = freezed,Object? images = freezed,Object? linkMaps = freezed,Object? eventoReferenciaId = freezed,Object? isDayAfterTransfer = freezed,Object? dados = freezed,Object? price = freezed,Object? siteUrl = freezed,Object? bookingStatus = freezed,}) {
  return _then(_ItineraryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
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
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,isDelayed: freezed == isDelayed ? _self.isDelayed : isDelayed // ignore: cast_nullable_to_non_nullable
as bool?,delay: freezed == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,durationString: freezed == durationString ? _self.durationString : durationString // ignore: cast_nullable_to_non_nullable
as String?,travelTime: freezed == travelTime ? _self.travelTime : travelTime // ignore: cast_nullable_to_non_nullable
as String?,connections: freezed == connections ? _self._connections : connections // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,escalas: freezed == escalas ? _self._escalas : escalas // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,estrelas: freezed == estrelas ? _self.estrelas : estrelas // ignore: cast_nullable_to_non_nullable
as double?,telefone: freezed == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>?,linkMaps: freezed == linkMaps ? _self.linkMaps : linkMaps // ignore: cast_nullable_to_non_nullable
as String?,eventoReferenciaId: freezed == eventoReferenciaId ? _self.eventoReferenciaId : eventoReferenciaId // ignore: cast_nullable_to_non_nullable
as String?,isDayAfterTransfer: freezed == isDayAfterTransfer ? _self.isDayAfterTransfer : isDayAfterTransfer // ignore: cast_nullable_to_non_nullable
as bool?,dados: freezed == dados ? _self._dados : dados // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as String?,bookingStatus: freezed == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
