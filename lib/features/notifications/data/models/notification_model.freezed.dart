// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

 String get id;@JsonKey(name: 'created_at') DateTime get createdAt; String? get mensagem; bool? get lido;@JsonKey(name: 'user_id') String? get userId; String? get assunto;@JsonKey(name: 'missao_id') String? get missionId;@JsonKey(name: 'post_id') String? get postId;@JsonKey(name: 'solicitacao_user_id') String? get solicitacaoUserId;@JsonKey(name: 'solicitacaorespondida') bool? get solicitacaoRespondida;@JsonKey(name: 'doc_id') String? get docId; String? get titulo; String? get icone;@JsonKey(name: 'grupo_id') String? get grupoId;// Joined data from users table (if any)
@JsonKey(ignore: true) String? get userName;@JsonKey(ignore: true) String? get userAvatar;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem)&&(identical(other.lido, lido) || other.lido == lido)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.assunto, assunto) || other.assunto == assunto)&&(identical(other.missionId, missionId) || other.missionId == missionId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.solicitacaoUserId, solicitacaoUserId) || other.solicitacaoUserId == solicitacaoUserId)&&(identical(other.solicitacaoRespondida, solicitacaoRespondida) || other.solicitacaoRespondida == solicitacaoRespondida)&&(identical(other.docId, docId) || other.docId == docId)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.icone, icone) || other.icone == icone)&&(identical(other.grupoId, grupoId) || other.grupoId == grupoId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,mensagem,lido,userId,assunto,missionId,postId,solicitacaoUserId,solicitacaoRespondida,docId,titulo,icone,grupoId,userName,userAvatar);

@override
String toString() {
  return 'NotificationModel(id: $id, createdAt: $createdAt, mensagem: $mensagem, lido: $lido, userId: $userId, assunto: $assunto, missionId: $missionId, postId: $postId, solicitacaoUserId: $solicitacaoUserId, solicitacaoRespondida: $solicitacaoRespondida, docId: $docId, titulo: $titulo, icone: $icone, grupoId: $grupoId, userName: $userName, userAvatar: $userAvatar)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'created_at') DateTime createdAt, String? mensagem, bool? lido,@JsonKey(name: 'user_id') String? userId, String? assunto,@JsonKey(name: 'missao_id') String? missionId,@JsonKey(name: 'post_id') String? postId,@JsonKey(name: 'solicitacao_user_id') String? solicitacaoUserId,@JsonKey(name: 'solicitacaorespondida') bool? solicitacaoRespondida,@JsonKey(name: 'doc_id') String? docId, String? titulo, String? icone,@JsonKey(name: 'grupo_id') String? grupoId,@JsonKey(ignore: true) String? userName,@JsonKey(ignore: true) String? userAvatar
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? mensagem = freezed,Object? lido = freezed,Object? userId = freezed,Object? assunto = freezed,Object? missionId = freezed,Object? postId = freezed,Object? solicitacaoUserId = freezed,Object? solicitacaoRespondida = freezed,Object? docId = freezed,Object? titulo = freezed,Object? icone = freezed,Object? grupoId = freezed,Object? userName = freezed,Object? userAvatar = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mensagem: freezed == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String?,lido: freezed == lido ? _self.lido : lido // ignore: cast_nullable_to_non_nullable
as bool?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,assunto: freezed == assunto ? _self.assunto : assunto // ignore: cast_nullable_to_non_nullable
as String?,missionId: freezed == missionId ? _self.missionId : missionId // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoUserId: freezed == solicitacaoUserId ? _self.solicitacaoUserId : solicitacaoUserId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoRespondida: freezed == solicitacaoRespondida ? _self.solicitacaoRespondida : solicitacaoRespondida // ignore: cast_nullable_to_non_nullable
as bool?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as String?,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,icone: freezed == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String?,grupoId: freezed == grupoId ? _self.grupoId : grupoId // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'created_at')  DateTime createdAt,  String? mensagem,  bool? lido, @JsonKey(name: 'user_id')  String? userId,  String? assunto, @JsonKey(name: 'missao_id')  String? missionId, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'solicitacao_user_id')  String? solicitacaoUserId, @JsonKey(name: 'solicitacaorespondida')  bool? solicitacaoRespondida, @JsonKey(name: 'doc_id')  String? docId,  String? titulo,  String? icone, @JsonKey(name: 'grupo_id')  String? grupoId, @JsonKey(ignore: true)  String? userName, @JsonKey(ignore: true)  String? userAvatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.mensagem,_that.lido,_that.userId,_that.assunto,_that.missionId,_that.postId,_that.solicitacaoUserId,_that.solicitacaoRespondida,_that.docId,_that.titulo,_that.icone,_that.grupoId,_that.userName,_that.userAvatar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'created_at')  DateTime createdAt,  String? mensagem,  bool? lido, @JsonKey(name: 'user_id')  String? userId,  String? assunto, @JsonKey(name: 'missao_id')  String? missionId, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'solicitacao_user_id')  String? solicitacaoUserId, @JsonKey(name: 'solicitacaorespondida')  bool? solicitacaoRespondida, @JsonKey(name: 'doc_id')  String? docId,  String? titulo,  String? icone, @JsonKey(name: 'grupo_id')  String? grupoId, @JsonKey(ignore: true)  String? userName, @JsonKey(ignore: true)  String? userAvatar)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.createdAt,_that.mensagem,_that.lido,_that.userId,_that.assunto,_that.missionId,_that.postId,_that.solicitacaoUserId,_that.solicitacaoRespondida,_that.docId,_that.titulo,_that.icone,_that.grupoId,_that.userName,_that.userAvatar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'created_at')  DateTime createdAt,  String? mensagem,  bool? lido, @JsonKey(name: 'user_id')  String? userId,  String? assunto, @JsonKey(name: 'missao_id')  String? missionId, @JsonKey(name: 'post_id')  String? postId, @JsonKey(name: 'solicitacao_user_id')  String? solicitacaoUserId, @JsonKey(name: 'solicitacaorespondida')  bool? solicitacaoRespondida, @JsonKey(name: 'doc_id')  String? docId,  String? titulo,  String? icone, @JsonKey(name: 'grupo_id')  String? grupoId, @JsonKey(ignore: true)  String? userName, @JsonKey(ignore: true)  String? userAvatar)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.createdAt,_that.mensagem,_that.lido,_that.userId,_that.assunto,_that.missionId,_that.postId,_that.solicitacaoUserId,_that.solicitacaoRespondida,_that.docId,_that.titulo,_that.icone,_that.grupoId,_that.userName,_that.userAvatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel extends NotificationModel {
  const _NotificationModel({required this.id, @JsonKey(name: 'created_at') required this.createdAt, required this.mensagem, required this.lido, @JsonKey(name: 'user_id') required this.userId, this.assunto, @JsonKey(name: 'missao_id') this.missionId, @JsonKey(name: 'post_id') this.postId, @JsonKey(name: 'solicitacao_user_id') this.solicitacaoUserId, @JsonKey(name: 'solicitacaorespondida') this.solicitacaoRespondida, @JsonKey(name: 'doc_id') this.docId, this.titulo, this.icone, @JsonKey(name: 'grupo_id') this.grupoId, @JsonKey(ignore: true) this.userName, @JsonKey(ignore: true) this.userAvatar}): super._();
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override final  String? mensagem;
@override final  bool? lido;
@override@JsonKey(name: 'user_id') final  String? userId;
@override final  String? assunto;
@override@JsonKey(name: 'missao_id') final  String? missionId;
@override@JsonKey(name: 'post_id') final  String? postId;
@override@JsonKey(name: 'solicitacao_user_id') final  String? solicitacaoUserId;
@override@JsonKey(name: 'solicitacaorespondida') final  bool? solicitacaoRespondida;
@override@JsonKey(name: 'doc_id') final  String? docId;
@override final  String? titulo;
@override final  String? icone;
@override@JsonKey(name: 'grupo_id') final  String? grupoId;
// Joined data from users table (if any)
@override@JsonKey(ignore: true) final  String? userName;
@override@JsonKey(ignore: true) final  String? userAvatar;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mensagem, mensagem) || other.mensagem == mensagem)&&(identical(other.lido, lido) || other.lido == lido)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.assunto, assunto) || other.assunto == assunto)&&(identical(other.missionId, missionId) || other.missionId == missionId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.solicitacaoUserId, solicitacaoUserId) || other.solicitacaoUserId == solicitacaoUserId)&&(identical(other.solicitacaoRespondida, solicitacaoRespondida) || other.solicitacaoRespondida == solicitacaoRespondida)&&(identical(other.docId, docId) || other.docId == docId)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.icone, icone) || other.icone == icone)&&(identical(other.grupoId, grupoId) || other.grupoId == grupoId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,mensagem,lido,userId,assunto,missionId,postId,solicitacaoUserId,solicitacaoRespondida,docId,titulo,icone,grupoId,userName,userAvatar);

@override
String toString() {
  return 'NotificationModel(id: $id, createdAt: $createdAt, mensagem: $mensagem, lido: $lido, userId: $userId, assunto: $assunto, missionId: $missionId, postId: $postId, solicitacaoUserId: $solicitacaoUserId, solicitacaoRespondida: $solicitacaoRespondida, docId: $docId, titulo: $titulo, icone: $icone, grupoId: $grupoId, userName: $userName, userAvatar: $userAvatar)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'created_at') DateTime createdAt, String? mensagem, bool? lido,@JsonKey(name: 'user_id') String? userId, String? assunto,@JsonKey(name: 'missao_id') String? missionId,@JsonKey(name: 'post_id') String? postId,@JsonKey(name: 'solicitacao_user_id') String? solicitacaoUserId,@JsonKey(name: 'solicitacaorespondida') bool? solicitacaoRespondida,@JsonKey(name: 'doc_id') String? docId, String? titulo, String? icone,@JsonKey(name: 'grupo_id') String? grupoId,@JsonKey(ignore: true) String? userName,@JsonKey(ignore: true) String? userAvatar
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? mensagem = freezed,Object? lido = freezed,Object? userId = freezed,Object? assunto = freezed,Object? missionId = freezed,Object? postId = freezed,Object? solicitacaoUserId = freezed,Object? solicitacaoRespondida = freezed,Object? docId = freezed,Object? titulo = freezed,Object? icone = freezed,Object? grupoId = freezed,Object? userName = freezed,Object? userAvatar = freezed,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mensagem: freezed == mensagem ? _self.mensagem : mensagem // ignore: cast_nullable_to_non_nullable
as String?,lido: freezed == lido ? _self.lido : lido // ignore: cast_nullable_to_non_nullable
as bool?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,assunto: freezed == assunto ? _self.assunto : assunto // ignore: cast_nullable_to_non_nullable
as String?,missionId: freezed == missionId ? _self.missionId : missionId // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoUserId: freezed == solicitacaoUserId ? _self.solicitacaoUserId : solicitacaoUserId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoRespondida: freezed == solicitacaoRespondida ? _self.solicitacaoRespondida : solicitacaoRespondida // ignore: cast_nullable_to_non_nullable
as bool?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as String?,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,icone: freezed == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String?,grupoId: freezed == grupoId ? _self.grupoId : grupoId // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
