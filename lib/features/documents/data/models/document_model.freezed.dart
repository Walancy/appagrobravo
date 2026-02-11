// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentModel {

 String get id;@JsonKey(name: 'user_id') String get userId; String? get tipo; String? get status;@JsonKey(name: 'foto_doc') String? get fotoDoc;@JsonKey(name: 'nome_documento') String? get nomeDocumento;@JsonKey(name: 'numero_documento') String? get numeroDocumento;@JsonKey(name: 'validade_doc') String? get validadeDoc;@JsonKey(name: 'data_envio') String? get dataEnvio;@JsonKey(name: 'motivoRecusa') String? get motivoRecusa;
/// Create a copy of DocumentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentModelCopyWith<DocumentModel> get copyWith => _$DocumentModelCopyWithImpl<DocumentModel>(this as DocumentModel, _$identity);

  /// Serializes this DocumentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.status, status) || other.status == status)&&(identical(other.fotoDoc, fotoDoc) || other.fotoDoc == fotoDoc)&&(identical(other.nomeDocumento, nomeDocumento) || other.nomeDocumento == nomeDocumento)&&(identical(other.numeroDocumento, numeroDocumento) || other.numeroDocumento == numeroDocumento)&&(identical(other.validadeDoc, validadeDoc) || other.validadeDoc == validadeDoc)&&(identical(other.dataEnvio, dataEnvio) || other.dataEnvio == dataEnvio)&&(identical(other.motivoRecusa, motivoRecusa) || other.motivoRecusa == motivoRecusa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tipo,status,fotoDoc,nomeDocumento,numeroDocumento,validadeDoc,dataEnvio,motivoRecusa);

@override
String toString() {
  return 'DocumentModel(id: $id, userId: $userId, tipo: $tipo, status: $status, fotoDoc: $fotoDoc, nomeDocumento: $nomeDocumento, numeroDocumento: $numeroDocumento, validadeDoc: $validadeDoc, dataEnvio: $dataEnvio, motivoRecusa: $motivoRecusa)';
}


}

/// @nodoc
abstract mixin class $DocumentModelCopyWith<$Res>  {
  factory $DocumentModelCopyWith(DocumentModel value, $Res Function(DocumentModel) _then) = _$DocumentModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? tipo, String? status,@JsonKey(name: 'foto_doc') String? fotoDoc,@JsonKey(name: 'nome_documento') String? nomeDocumento,@JsonKey(name: 'numero_documento') String? numeroDocumento,@JsonKey(name: 'validade_doc') String? validadeDoc,@JsonKey(name: 'data_envio') String? dataEnvio,@JsonKey(name: 'motivoRecusa') String? motivoRecusa
});




}
/// @nodoc
class _$DocumentModelCopyWithImpl<$Res>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._self, this._then);

  final DocumentModel _self;
  final $Res Function(DocumentModel) _then;

/// Create a copy of DocumentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? tipo = freezed,Object? status = freezed,Object? fotoDoc = freezed,Object? nomeDocumento = freezed,Object? numeroDocumento = freezed,Object? validadeDoc = freezed,Object? dataEnvio = freezed,Object? motivoRecusa = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,fotoDoc: freezed == fotoDoc ? _self.fotoDoc : fotoDoc // ignore: cast_nullable_to_non_nullable
as String?,nomeDocumento: freezed == nomeDocumento ? _self.nomeDocumento : nomeDocumento // ignore: cast_nullable_to_non_nullable
as String?,numeroDocumento: freezed == numeroDocumento ? _self.numeroDocumento : numeroDocumento // ignore: cast_nullable_to_non_nullable
as String?,validadeDoc: freezed == validadeDoc ? _self.validadeDoc : validadeDoc // ignore: cast_nullable_to_non_nullable
as String?,dataEnvio: freezed == dataEnvio ? _self.dataEnvio : dataEnvio // ignore: cast_nullable_to_non_nullable
as String?,motivoRecusa: freezed == motivoRecusa ? _self.motivoRecusa : motivoRecusa // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentModel].
extension DocumentModelPatterns on DocumentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? tipo,  String? status, @JsonKey(name: 'foto_doc')  String? fotoDoc, @JsonKey(name: 'nome_documento')  String? nomeDocumento, @JsonKey(name: 'numero_documento')  String? numeroDocumento, @JsonKey(name: 'validade_doc')  String? validadeDoc, @JsonKey(name: 'data_envio')  String? dataEnvio, @JsonKey(name: 'motivoRecusa')  String? motivoRecusa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentModel() when $default != null:
return $default(_that.id,_that.userId,_that.tipo,_that.status,_that.fotoDoc,_that.nomeDocumento,_that.numeroDocumento,_that.validadeDoc,_that.dataEnvio,_that.motivoRecusa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String? tipo,  String? status, @JsonKey(name: 'foto_doc')  String? fotoDoc, @JsonKey(name: 'nome_documento')  String? nomeDocumento, @JsonKey(name: 'numero_documento')  String? numeroDocumento, @JsonKey(name: 'validade_doc')  String? validadeDoc, @JsonKey(name: 'data_envio')  String? dataEnvio, @JsonKey(name: 'motivoRecusa')  String? motivoRecusa)  $default,) {final _that = this;
switch (_that) {
case _DocumentModel():
return $default(_that.id,_that.userId,_that.tipo,_that.status,_that.fotoDoc,_that.nomeDocumento,_that.numeroDocumento,_that.validadeDoc,_that.dataEnvio,_that.motivoRecusa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String? tipo,  String? status, @JsonKey(name: 'foto_doc')  String? fotoDoc, @JsonKey(name: 'nome_documento')  String? nomeDocumento, @JsonKey(name: 'numero_documento')  String? numeroDocumento, @JsonKey(name: 'validade_doc')  String? validadeDoc, @JsonKey(name: 'data_envio')  String? dataEnvio, @JsonKey(name: 'motivoRecusa')  String? motivoRecusa)?  $default,) {final _that = this;
switch (_that) {
case _DocumentModel() when $default != null:
return $default(_that.id,_that.userId,_that.tipo,_that.status,_that.fotoDoc,_that.nomeDocumento,_that.numeroDocumento,_that.validadeDoc,_that.dataEnvio,_that.motivoRecusa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentModel extends DocumentModel {
  const _DocumentModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.tipo, required this.status, @JsonKey(name: 'foto_doc') required this.fotoDoc, @JsonKey(name: 'nome_documento') required this.nomeDocumento, @JsonKey(name: 'numero_documento') required this.numeroDocumento, @JsonKey(name: 'validade_doc') required this.validadeDoc, @JsonKey(name: 'data_envio') required this.dataEnvio, @JsonKey(name: 'motivoRecusa') required this.motivoRecusa}): super._();
  factory _DocumentModel.fromJson(Map<String, dynamic> json) => _$DocumentModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String? tipo;
@override final  String? status;
@override@JsonKey(name: 'foto_doc') final  String? fotoDoc;
@override@JsonKey(name: 'nome_documento') final  String? nomeDocumento;
@override@JsonKey(name: 'numero_documento') final  String? numeroDocumento;
@override@JsonKey(name: 'validade_doc') final  String? validadeDoc;
@override@JsonKey(name: 'data_envio') final  String? dataEnvio;
@override@JsonKey(name: 'motivoRecusa') final  String? motivoRecusa;

/// Create a copy of DocumentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentModelCopyWith<_DocumentModel> get copyWith => __$DocumentModelCopyWithImpl<_DocumentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.status, status) || other.status == status)&&(identical(other.fotoDoc, fotoDoc) || other.fotoDoc == fotoDoc)&&(identical(other.nomeDocumento, nomeDocumento) || other.nomeDocumento == nomeDocumento)&&(identical(other.numeroDocumento, numeroDocumento) || other.numeroDocumento == numeroDocumento)&&(identical(other.validadeDoc, validadeDoc) || other.validadeDoc == validadeDoc)&&(identical(other.dataEnvio, dataEnvio) || other.dataEnvio == dataEnvio)&&(identical(other.motivoRecusa, motivoRecusa) || other.motivoRecusa == motivoRecusa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tipo,status,fotoDoc,nomeDocumento,numeroDocumento,validadeDoc,dataEnvio,motivoRecusa);

@override
String toString() {
  return 'DocumentModel(id: $id, userId: $userId, tipo: $tipo, status: $status, fotoDoc: $fotoDoc, nomeDocumento: $nomeDocumento, numeroDocumento: $numeroDocumento, validadeDoc: $validadeDoc, dataEnvio: $dataEnvio, motivoRecusa: $motivoRecusa)';
}


}

/// @nodoc
abstract mixin class _$DocumentModelCopyWith<$Res> implements $DocumentModelCopyWith<$Res> {
  factory _$DocumentModelCopyWith(_DocumentModel value, $Res Function(_DocumentModel) _then) = __$DocumentModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? tipo, String? status,@JsonKey(name: 'foto_doc') String? fotoDoc,@JsonKey(name: 'nome_documento') String? nomeDocumento,@JsonKey(name: 'numero_documento') String? numeroDocumento,@JsonKey(name: 'validade_doc') String? validadeDoc,@JsonKey(name: 'data_envio') String? dataEnvio,@JsonKey(name: 'motivoRecusa') String? motivoRecusa
});




}
/// @nodoc
class __$DocumentModelCopyWithImpl<$Res>
    implements _$DocumentModelCopyWith<$Res> {
  __$DocumentModelCopyWithImpl(this._self, this._then);

  final _DocumentModel _self;
  final $Res Function(_DocumentModel) _then;

/// Create a copy of DocumentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? tipo = freezed,Object? status = freezed,Object? fotoDoc = freezed,Object? nomeDocumento = freezed,Object? numeroDocumento = freezed,Object? validadeDoc = freezed,Object? dataEnvio = freezed,Object? motivoRecusa = freezed,}) {
  return _then(_DocumentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,fotoDoc: freezed == fotoDoc ? _self.fotoDoc : fotoDoc // ignore: cast_nullable_to_non_nullable
as String?,nomeDocumento: freezed == nomeDocumento ? _self.nomeDocumento : nomeDocumento // ignore: cast_nullable_to_non_nullable
as String?,numeroDocumento: freezed == numeroDocumento ? _self.numeroDocumento : numeroDocumento // ignore: cast_nullable_to_non_nullable
as String?,validadeDoc: freezed == validadeDoc ? _self.validadeDoc : validadeDoc // ignore: cast_nullable_to_non_nullable
as String?,dataEnvio: freezed == dataEnvio ? _self.dataEnvio : dataEnvio // ignore: cast_nullable_to_non_nullable
as String?,motivoRecusa: freezed == motivoRecusa ? _self.motivoRecusa : motivoRecusa // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
