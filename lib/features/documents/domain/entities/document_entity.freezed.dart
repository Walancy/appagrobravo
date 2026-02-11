// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentEntity {

 String get id; DocumentType get type; DocumentStatus get status; String? get imageUrl; String? get title; String? get documentNumber; DateTime? get expiryDate; DateTime? get uploadDate; String? get rejectionReason;
/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<DocumentEntity> get copyWith => _$DocumentEntityCopyWithImpl<DocumentEntity>(this as DocumentEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,status,imageUrl,title,documentNumber,expiryDate,uploadDate,rejectionReason);

@override
String toString() {
  return 'DocumentEntity(id: $id, type: $type, status: $status, imageUrl: $imageUrl, title: $title, documentNumber: $documentNumber, expiryDate: $expiryDate, uploadDate: $uploadDate, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class $DocumentEntityCopyWith<$Res>  {
  factory $DocumentEntityCopyWith(DocumentEntity value, $Res Function(DocumentEntity) _then) = _$DocumentEntityCopyWithImpl;
@useResult
$Res call({
 String id, DocumentType type, DocumentStatus status, String? imageUrl, String? title, String? documentNumber, DateTime? expiryDate, DateTime? uploadDate, String? rejectionReason
});




}
/// @nodoc
class _$DocumentEntityCopyWithImpl<$Res>
    implements $DocumentEntityCopyWith<$Res> {
  _$DocumentEntityCopyWithImpl(this._self, this._then);

  final DocumentEntity _self;
  final $Res Function(DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? imageUrl = freezed,Object? title = freezed,Object? documentNumber = freezed,Object? expiryDate = freezed,Object? uploadDate = freezed,Object? rejectionReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,documentNumber: freezed == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentEntity].
extension DocumentEntityPatterns on DocumentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentEntity value)  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DocumentType type,  DocumentStatus status,  String? imageUrl,  String? title,  String? documentNumber,  DateTime? expiryDate,  DateTime? uploadDate,  String? rejectionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.imageUrl,_that.title,_that.documentNumber,_that.expiryDate,_that.uploadDate,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DocumentType type,  DocumentStatus status,  String? imageUrl,  String? title,  String? documentNumber,  DateTime? expiryDate,  DateTime? uploadDate,  String? rejectionReason)  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity():
return $default(_that.id,_that.type,_that.status,_that.imageUrl,_that.title,_that.documentNumber,_that.expiryDate,_that.uploadDate,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DocumentType type,  DocumentStatus status,  String? imageUrl,  String? title,  String? documentNumber,  DateTime? expiryDate,  DateTime? uploadDate,  String? rejectionReason)?  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.imageUrl,_that.title,_that.documentNumber,_that.expiryDate,_that.uploadDate,_that.rejectionReason);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentEntity implements DocumentEntity {
  const _DocumentEntity({required this.id, required this.type, required this.status, required this.imageUrl, required this.title, required this.documentNumber, required this.expiryDate, required this.uploadDate, required this.rejectionReason});
  

@override final  String id;
@override final  DocumentType type;
@override final  DocumentStatus status;
@override final  String? imageUrl;
@override final  String? title;
@override final  String? documentNumber;
@override final  DateTime? expiryDate;
@override final  DateTime? uploadDate;
@override final  String? rejectionReason;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentEntityCopyWith<_DocumentEntity> get copyWith => __$DocumentEntityCopyWithImpl<_DocumentEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.documentNumber, documentNumber) || other.documentNumber == documentNumber)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.uploadDate, uploadDate) || other.uploadDate == uploadDate)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,status,imageUrl,title,documentNumber,expiryDate,uploadDate,rejectionReason);

@override
String toString() {
  return 'DocumentEntity(id: $id, type: $type, status: $status, imageUrl: $imageUrl, title: $title, documentNumber: $documentNumber, expiryDate: $expiryDate, uploadDate: $uploadDate, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class _$DocumentEntityCopyWith<$Res> implements $DocumentEntityCopyWith<$Res> {
  factory _$DocumentEntityCopyWith(_DocumentEntity value, $Res Function(_DocumentEntity) _then) = __$DocumentEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, DocumentType type, DocumentStatus status, String? imageUrl, String? title, String? documentNumber, DateTime? expiryDate, DateTime? uploadDate, String? rejectionReason
});




}
/// @nodoc
class __$DocumentEntityCopyWithImpl<$Res>
    implements _$DocumentEntityCopyWith<$Res> {
  __$DocumentEntityCopyWithImpl(this._self, this._then);

  final _DocumentEntity _self;
  final $Res Function(_DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? imageUrl = freezed,Object? title = freezed,Object? documentNumber = freezed,Object? expiryDate = freezed,Object? uploadDate = freezed,Object? rejectionReason = freezed,}) {
  return _then(_DocumentEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,documentNumber: freezed == documentNumber ? _self.documentNumber : documentNumber // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,uploadDate: freezed == uploadDate ? _self.uploadDate : uploadDate // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
