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

 String get id; String get name; ItineraryType get type; DateTime? get startDateTime; DateTime? get endDateTime; String? get description; String? get location; String? get imageUrl;// Subtitle label (check-in / check-out from panel)
 String? get subtitle;// Flight specific
 String? get fromCode; String? get toCode; String? get fromCity; String? get toCity; String? get fromTime; String? get toTime; bool? get isDelayed; String? get delay;// Transfer specific
 String? get driverName; String? get durationString; String? get travelTime; List<Map<String, dynamic>>? get connections;// Enriched location (new DB columns from panel)
 String? get address; String? get city; String? get state; String? get country; double? get latitude; double? get longitude; double? get rating; double? get estrelas; String? get telefone; String? get website; List<String>? get images; String? get linkMaps;// Transfer
 String? get transportMode; String? get eventoReferenciaId; bool? get isDayAfterTransfer; String? get transferDate; String? get transferTime;// Booking info
 String? get price; String? get siteUrl; String? get bookingStatus;// Hotel / venue extras (from dados JSONB)
 List<String>? get amenities; String? get hotelDescription; String? get planeType;// Attachments (per-event documents/links from panel)
 List<Map<String, dynamic>>? get attachments;// Google Places deep link
 String? get placeId;
/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryItemEntityCopyWith<ItineraryItemEntity> get copyWith => _$ItineraryItemEntityCopyWithImpl<ItineraryItemEntity>(this as ItineraryItemEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDateTime, startDateTime) || other.startDateTime == startDateTime)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.isDelayed, isDelayed) || other.isDelayed == isDelayed)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other.connections, connections)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.estrelas, estrelas) || other.estrelas == estrelas)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.linkMaps, linkMaps) || other.linkMaps == linkMaps)&&(identical(other.transportMode, transportMode) || other.transportMode == transportMode)&&(identical(other.eventoReferenciaId, eventoReferenciaId) || other.eventoReferenciaId == eventoReferenciaId)&&(identical(other.isDayAfterTransfer, isDayAfterTransfer) || other.isDayAfterTransfer == isDayAfterTransfer)&&(identical(other.transferDate, transferDate) || other.transferDate == transferDate)&&(identical(other.transferTime, transferTime) || other.transferTime == transferTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.siteUrl, siteUrl) || other.siteUrl == siteUrl)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&(identical(other.hotelDescription, hotelDescription) || other.hotelDescription == hotelDescription)&&(identical(other.planeType, planeType) || other.planeType == planeType)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.placeId, placeId) || other.placeId == placeId));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,startDateTime,endDateTime,description,location,imageUrl,subtitle,fromCode,toCode,fromCity,toCity,fromTime,toTime,isDelayed,delay,driverName,durationString,travelTime,const DeepCollectionEquality().hash(connections),address,city,state,country,latitude,longitude,rating,estrelas,telefone,website,const DeepCollectionEquality().hash(images),linkMaps,transportMode,eventoReferenciaId,isDayAfterTransfer,transferDate,transferTime,price,siteUrl,bookingStatus,const DeepCollectionEquality().hash(amenities),hotelDescription,planeType,const DeepCollectionEquality().hash(attachments),placeId]);

@override
String toString() {
  return 'ItineraryItemEntity(id: $id, name: $name, type: $type, startDateTime: $startDateTime, endDateTime: $endDateTime, description: $description, location: $location, imageUrl: $imageUrl, subtitle: $subtitle, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, fromTime: $fromTime, toTime: $toTime, isDelayed: $isDelayed, delay: $delay, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections, address: $address, city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude, rating: $rating, estrelas: $estrelas, telefone: $telefone, website: $website, images: $images, linkMaps: $linkMaps, transportMode: $transportMode, eventoReferenciaId: $eventoReferenciaId, isDayAfterTransfer: $isDayAfterTransfer, transferDate: $transferDate, transferTime: $transferTime, price: $price, siteUrl: $siteUrl, bookingStatus: $bookingStatus, amenities: $amenities, hotelDescription: $hotelDescription, planeType: $planeType, attachments: $attachments, placeId: $placeId)';
}


}

/// @nodoc
abstract mixin class $ItineraryItemEntityCopyWith<$Res>  {
  factory $ItineraryItemEntityCopyWith(ItineraryItemEntity value, $Res Function(ItineraryItemEntity) _then) = _$ItineraryItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, ItineraryType type, DateTime? startDateTime, DateTime? endDateTime, String? description, String? location, String? imageUrl, String? subtitle, String? fromCode, String? toCode, String? fromCity, String? toCity, String? fromTime, String? toTime, bool? isDelayed, String? delay, String? driverName, String? durationString, String? travelTime, List<Map<String, dynamic>>? connections, String? address, String? city, String? state, String? country, double? latitude, double? longitude, double? rating, double? estrelas, String? telefone, String? website, List<String>? images, String? linkMaps, String? transportMode, String? eventoReferenciaId, bool? isDayAfterTransfer, String? transferDate, String? transferTime, String? price, String? siteUrl, String? bookingStatus, List<String>? amenities, String? hotelDescription, String? planeType, List<Map<String, dynamic>>? attachments, String? placeId
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? startDateTime = freezed,Object? endDateTime = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? subtitle = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? isDelayed = freezed,Object? delay = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? rating = freezed,Object? estrelas = freezed,Object? telefone = freezed,Object? website = freezed,Object? images = freezed,Object? linkMaps = freezed,Object? transportMode = freezed,Object? eventoReferenciaId = freezed,Object? isDayAfterTransfer = freezed,Object? transferDate = freezed,Object? transferTime = freezed,Object? price = freezed,Object? siteUrl = freezed,Object? bookingStatus = freezed,Object? amenities = freezed,Object? hotelDescription = freezed,Object? planeType = freezed,Object? attachments = freezed,Object? placeId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItineraryType,startDateTime: freezed == startDateTime ? _self.startDateTime : startDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
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
as String?,transportMode: freezed == transportMode ? _self.transportMode : transportMode // ignore: cast_nullable_to_non_nullable
as String?,eventoReferenciaId: freezed == eventoReferenciaId ? _self.eventoReferenciaId : eventoReferenciaId // ignore: cast_nullable_to_non_nullable
as String?,isDayAfterTransfer: freezed == isDayAfterTransfer ? _self.isDayAfterTransfer : isDayAfterTransfer // ignore: cast_nullable_to_non_nullable
as bool?,transferDate: freezed == transferDate ? _self.transferDate : transferDate // ignore: cast_nullable_to_non_nullable
as String?,transferTime: freezed == transferTime ? _self.transferTime : transferTime // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as String?,bookingStatus: freezed == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String?,amenities: freezed == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>?,hotelDescription: freezed == hotelDescription ? _self.hotelDescription : hotelDescription // ignore: cast_nullable_to_non_nullable
as String?,planeType: freezed == planeType ? _self.planeType : planeType // ignore: cast_nullable_to_non_nullable
as String?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? subtitle,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? fromTime,  String? toTime,  bool? isDelayed,  String? delay,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections,  String? address,  String? city,  String? state,  String? country,  double? latitude,  double? longitude,  double? rating,  double? estrelas,  String? telefone,  String? website,  List<String>? images,  String? linkMaps,  String? transportMode,  String? eventoReferenciaId,  bool? isDayAfterTransfer,  String? transferDate,  String? transferTime,  String? price,  String? siteUrl,  String? bookingStatus,  List<String>? amenities,  String? hotelDescription,  String? planeType,  List<Map<String, dynamic>>? attachments,  String? placeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.subtitle,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.transportMode,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.transferDate,_that.transferTime,_that.price,_that.siteUrl,_that.bookingStatus,_that.amenities,_that.hotelDescription,_that.planeType,_that.attachments,_that.placeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? subtitle,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? fromTime,  String? toTime,  bool? isDelayed,  String? delay,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections,  String? address,  String? city,  String? state,  String? country,  double? latitude,  double? longitude,  double? rating,  double? estrelas,  String? telefone,  String? website,  List<String>? images,  String? linkMaps,  String? transportMode,  String? eventoReferenciaId,  bool? isDayAfterTransfer,  String? transferDate,  String? transferTime,  String? price,  String? siteUrl,  String? bookingStatus,  List<String>? amenities,  String? hotelDescription,  String? planeType,  List<Map<String, dynamic>>? attachments,  String? placeId)  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemEntity():
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.subtitle,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.transportMode,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.transferDate,_that.transferTime,_that.price,_that.siteUrl,_that.bookingStatus,_that.amenities,_that.hotelDescription,_that.planeType,_that.attachments,_that.placeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ItineraryType type,  DateTime? startDateTime,  DateTime? endDateTime,  String? description,  String? location,  String? imageUrl,  String? subtitle,  String? fromCode,  String? toCode,  String? fromCity,  String? toCity,  String? fromTime,  String? toTime,  bool? isDelayed,  String? delay,  String? driverName,  String? durationString,  String? travelTime,  List<Map<String, dynamic>>? connections,  String? address,  String? city,  String? state,  String? country,  double? latitude,  double? longitude,  double? rating,  double? estrelas,  String? telefone,  String? website,  List<String>? images,  String? linkMaps,  String? transportMode,  String? eventoReferenciaId,  bool? isDayAfterTransfer,  String? transferDate,  String? transferTime,  String? price,  String? siteUrl,  String? bookingStatus,  List<String>? amenities,  String? hotelDescription,  String? planeType,  List<Map<String, dynamic>>? attachments,  String? placeId)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryItemEntity() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.startDateTime,_that.endDateTime,_that.description,_that.location,_that.imageUrl,_that.subtitle,_that.fromCode,_that.toCode,_that.fromCity,_that.toCity,_that.fromTime,_that.toTime,_that.isDelayed,_that.delay,_that.driverName,_that.durationString,_that.travelTime,_that.connections,_that.address,_that.city,_that.state,_that.country,_that.latitude,_that.longitude,_that.rating,_that.estrelas,_that.telefone,_that.website,_that.images,_that.linkMaps,_that.transportMode,_that.eventoReferenciaId,_that.isDayAfterTransfer,_that.transferDate,_that.transferTime,_that.price,_that.siteUrl,_that.bookingStatus,_that.amenities,_that.hotelDescription,_that.planeType,_that.attachments,_that.placeId);case _:
  return null;

}
}

}

/// @nodoc


class _ItineraryItemEntity extends ItineraryItemEntity {
  const _ItineraryItemEntity({required this.id, required this.name, required this.type, this.startDateTime, this.endDateTime, this.description, this.location, this.imageUrl, this.subtitle, this.fromCode, this.toCode, this.fromCity, this.toCity, this.fromTime, this.toTime, this.isDelayed, this.delay, this.driverName, this.durationString, this.travelTime, final  List<Map<String, dynamic>>? connections, this.address, this.city, this.state, this.country, this.latitude, this.longitude, this.rating, this.estrelas, this.telefone, this.website, final  List<String>? images, this.linkMaps, this.transportMode, this.eventoReferenciaId, this.isDayAfterTransfer, this.transferDate, this.transferTime, this.price, this.siteUrl, this.bookingStatus, final  List<String>? amenities, this.hotelDescription, this.planeType, final  List<Map<String, dynamic>>? attachments, this.placeId}): _connections = connections,_images = images,_amenities = amenities,_attachments = attachments,super._();
  

@override final  String id;
@override final  String name;
@override final  ItineraryType type;
@override final  DateTime? startDateTime;
@override final  DateTime? endDateTime;
@override final  String? description;
@override final  String? location;
@override final  String? imageUrl;
// Subtitle label (check-in / check-out from panel)
@override final  String? subtitle;
// Flight specific
@override final  String? fromCode;
@override final  String? toCode;
@override final  String? fromCity;
@override final  String? toCity;
@override final  String? fromTime;
@override final  String? toTime;
@override final  bool? isDelayed;
@override final  String? delay;
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

// Enriched location (new DB columns from panel)
@override final  String? address;
@override final  String? city;
@override final  String? state;
@override final  String? country;
@override final  double? latitude;
@override final  double? longitude;
@override final  double? rating;
@override final  double? estrelas;
@override final  String? telefone;
@override final  String? website;
 final  List<String>? _images;
@override List<String>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? linkMaps;
// Transfer
@override final  String? transportMode;
@override final  String? eventoReferenciaId;
@override final  bool? isDayAfterTransfer;
@override final  String? transferDate;
@override final  String? transferTime;
// Booking info
@override final  String? price;
@override final  String? siteUrl;
@override final  String? bookingStatus;
// Hotel / venue extras (from dados JSONB)
 final  List<String>? _amenities;
// Hotel / venue extras (from dados JSONB)
@override List<String>? get amenities {
  final value = _amenities;
  if (value == null) return null;
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? hotelDescription;
@override final  String? planeType;
// Attachments (per-event documents/links from panel)
 final  List<Map<String, dynamic>>? _attachments;
// Attachments (per-event documents/links from panel)
@override List<Map<String, dynamic>>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Google Places deep link
@override final  String? placeId;

/// Create a copy of ItineraryItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryItemEntityCopyWith<_ItineraryItemEntity> get copyWith => __$ItineraryItemEntityCopyWithImpl<_ItineraryItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDateTime, startDateTime) || other.startDateTime == startDateTime)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.fromCode, fromCode) || other.fromCode == fromCode)&&(identical(other.toCode, toCode) || other.toCode == toCode)&&(identical(other.fromCity, fromCity) || other.fromCity == fromCity)&&(identical(other.toCity, toCity) || other.toCity == toCity)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.isDelayed, isDelayed) || other.isDelayed == isDelayed)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.durationString, durationString) || other.durationString == durationString)&&(identical(other.travelTime, travelTime) || other.travelTime == travelTime)&&const DeepCollectionEquality().equals(other._connections, _connections)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.estrelas, estrelas) || other.estrelas == estrelas)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.website, website) || other.website == website)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.linkMaps, linkMaps) || other.linkMaps == linkMaps)&&(identical(other.transportMode, transportMode) || other.transportMode == transportMode)&&(identical(other.eventoReferenciaId, eventoReferenciaId) || other.eventoReferenciaId == eventoReferenciaId)&&(identical(other.isDayAfterTransfer, isDayAfterTransfer) || other.isDayAfterTransfer == isDayAfterTransfer)&&(identical(other.transferDate, transferDate) || other.transferDate == transferDate)&&(identical(other.transferTime, transferTime) || other.transferTime == transferTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.siteUrl, siteUrl) || other.siteUrl == siteUrl)&&(identical(other.bookingStatus, bookingStatus) || other.bookingStatus == bookingStatus)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&(identical(other.hotelDescription, hotelDescription) || other.hotelDescription == hotelDescription)&&(identical(other.planeType, planeType) || other.planeType == planeType)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.placeId, placeId) || other.placeId == placeId));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,startDateTime,endDateTime,description,location,imageUrl,subtitle,fromCode,toCode,fromCity,toCity,fromTime,toTime,isDelayed,delay,driverName,durationString,travelTime,const DeepCollectionEquality().hash(_connections),address,city,state,country,latitude,longitude,rating,estrelas,telefone,website,const DeepCollectionEquality().hash(_images),linkMaps,transportMode,eventoReferenciaId,isDayAfterTransfer,transferDate,transferTime,price,siteUrl,bookingStatus,const DeepCollectionEquality().hash(_amenities),hotelDescription,planeType,const DeepCollectionEquality().hash(_attachments),placeId]);

@override
String toString() {
  return 'ItineraryItemEntity(id: $id, name: $name, type: $type, startDateTime: $startDateTime, endDateTime: $endDateTime, description: $description, location: $location, imageUrl: $imageUrl, subtitle: $subtitle, fromCode: $fromCode, toCode: $toCode, fromCity: $fromCity, toCity: $toCity, fromTime: $fromTime, toTime: $toTime, isDelayed: $isDelayed, delay: $delay, driverName: $driverName, durationString: $durationString, travelTime: $travelTime, connections: $connections, address: $address, city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude, rating: $rating, estrelas: $estrelas, telefone: $telefone, website: $website, images: $images, linkMaps: $linkMaps, transportMode: $transportMode, eventoReferenciaId: $eventoReferenciaId, isDayAfterTransfer: $isDayAfterTransfer, transferDate: $transferDate, transferTime: $transferTime, price: $price, siteUrl: $siteUrl, bookingStatus: $bookingStatus, amenities: $amenities, hotelDescription: $hotelDescription, planeType: $planeType, attachments: $attachments, placeId: $placeId)';
}


}

/// @nodoc
abstract mixin class _$ItineraryItemEntityCopyWith<$Res> implements $ItineraryItemEntityCopyWith<$Res> {
  factory _$ItineraryItemEntityCopyWith(_ItineraryItemEntity value, $Res Function(_ItineraryItemEntity) _then) = __$ItineraryItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ItineraryType type, DateTime? startDateTime, DateTime? endDateTime, String? description, String? location, String? imageUrl, String? subtitle, String? fromCode, String? toCode, String? fromCity, String? toCity, String? fromTime, String? toTime, bool? isDelayed, String? delay, String? driverName, String? durationString, String? travelTime, List<Map<String, dynamic>>? connections, String? address, String? city, String? state, String? country, double? latitude, double? longitude, double? rating, double? estrelas, String? telefone, String? website, List<String>? images, String? linkMaps, String? transportMode, String? eventoReferenciaId, bool? isDayAfterTransfer, String? transferDate, String? transferTime, String? price, String? siteUrl, String? bookingStatus, List<String>? amenities, String? hotelDescription, String? planeType, List<Map<String, dynamic>>? attachments, String? placeId
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? startDateTime = freezed,Object? endDateTime = freezed,Object? description = freezed,Object? location = freezed,Object? imageUrl = freezed,Object? subtitle = freezed,Object? fromCode = freezed,Object? toCode = freezed,Object? fromCity = freezed,Object? toCity = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? isDelayed = freezed,Object? delay = freezed,Object? driverName = freezed,Object? durationString = freezed,Object? travelTime = freezed,Object? connections = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? rating = freezed,Object? estrelas = freezed,Object? telefone = freezed,Object? website = freezed,Object? images = freezed,Object? linkMaps = freezed,Object? transportMode = freezed,Object? eventoReferenciaId = freezed,Object? isDayAfterTransfer = freezed,Object? transferDate = freezed,Object? transferTime = freezed,Object? price = freezed,Object? siteUrl = freezed,Object? bookingStatus = freezed,Object? amenities = freezed,Object? hotelDescription = freezed,Object? planeType = freezed,Object? attachments = freezed,Object? placeId = freezed,}) {
  return _then(_ItineraryItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ItineraryType,startDateTime: freezed == startDateTime ? _self.startDateTime : startDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
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
as String?,transportMode: freezed == transportMode ? _self.transportMode : transportMode // ignore: cast_nullable_to_non_nullable
as String?,eventoReferenciaId: freezed == eventoReferenciaId ? _self.eventoReferenciaId : eventoReferenciaId // ignore: cast_nullable_to_non_nullable
as String?,isDayAfterTransfer: freezed == isDayAfterTransfer ? _self.isDayAfterTransfer : isDayAfterTransfer // ignore: cast_nullable_to_non_nullable
as bool?,transferDate: freezed == transferDate ? _self.transferDate : transferDate // ignore: cast_nullable_to_non_nullable
as String?,transferTime: freezed == transferTime ? _self.transferTime : transferTime // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,siteUrl: freezed == siteUrl ? _self.siteUrl : siteUrl // ignore: cast_nullable_to_non_nullable
as String?,bookingStatus: freezed == bookingStatus ? _self.bookingStatus : bookingStatus // ignore: cast_nullable_to_non_nullable
as String?,amenities: freezed == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>?,hotelDescription: freezed == hotelDescription ? _self.hotelDescription : hotelDescription // ignore: cast_nullable_to_non_nullable
as String?,planeType: freezed == planeType ? _self.planeType : planeType // ignore: cast_nullable_to_non_nullable
as String?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
