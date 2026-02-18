// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'missao_id') String? get missaoId; List<String> get imagens; String get legenda;@JsonKey(name: 'n_curtidas') int get likesCount;@JsonKey(name: 'n_comentarios') int get commentsCount;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'privado') bool get privado;// Joined data
 String? get userName; String? get userAvatar; String? get missionName; bool get isLiked;
/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostModelCopyWith<PostModel> get copyWith => _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.missaoId, missaoId) || other.missaoId == missaoId)&&const DeepCollectionEquality().equals(other.imagens, imagens)&&(identical(other.legenda, legenda) || other.legenda == legenda)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.privado, privado) || other.privado == privado)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,missaoId,const DeepCollectionEquality().hash(imagens),legenda,likesCount,commentsCount,createdAt,privado,userName,userAvatar,missionName,isLiked);

@override
String toString() {
  return 'PostModel(id: $id, userId: $userId, missaoId: $missaoId, imagens: $imagens, legenda: $legenda, likesCount: $likesCount, commentsCount: $commentsCount, createdAt: $createdAt, privado: $privado, userName: $userName, userAvatar: $userAvatar, missionName: $missionName, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res>  {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) = _$PostModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'missao_id') String? missaoId, List<String> imagens, String legenda,@JsonKey(name: 'n_curtidas') int likesCount,@JsonKey(name: 'n_comentarios') int commentsCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'privado') bool privado, String? userName, String? userAvatar, String? missionName, bool isLiked
});




}
/// @nodoc
class _$PostModelCopyWithImpl<$Res>
    implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? missaoId = freezed,Object? imagens = null,Object? legenda = null,Object? likesCount = null,Object? commentsCount = null,Object? createdAt = null,Object? privado = null,Object? userName = freezed,Object? userAvatar = freezed,Object? missionName = freezed,Object? isLiked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,missaoId: freezed == missaoId ? _self.missaoId : missaoId // ignore: cast_nullable_to_non_nullable
as String?,imagens: null == imagens ? _self.imagens : imagens // ignore: cast_nullable_to_non_nullable
as List<String>,legenda: null == legenda ? _self.legenda : legenda // ignore: cast_nullable_to_non_nullable
as String,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,privado: null == privado ? _self.privado : privado // ignore: cast_nullable_to_non_nullable
as bool,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostModel].
extension PostModelPatterns on PostModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostModel value)  $default,){
final _that = this;
switch (_that) {
case _PostModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostModel value)?  $default,){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'missao_id')  String? missaoId,  List<String> imagens,  String legenda, @JsonKey(name: 'n_curtidas')  int likesCount, @JsonKey(name: 'n_comentarios')  int commentsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'privado')  bool privado,  String? userName,  String? userAvatar,  String? missionName,  bool isLiked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.id,_that.userId,_that.missaoId,_that.imagens,_that.legenda,_that.likesCount,_that.commentsCount,_that.createdAt,_that.privado,_that.userName,_that.userAvatar,_that.missionName,_that.isLiked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'missao_id')  String? missaoId,  List<String> imagens,  String legenda, @JsonKey(name: 'n_curtidas')  int likesCount, @JsonKey(name: 'n_comentarios')  int commentsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'privado')  bool privado,  String? userName,  String? userAvatar,  String? missionName,  bool isLiked)  $default,) {final _that = this;
switch (_that) {
case _PostModel():
return $default(_that.id,_that.userId,_that.missaoId,_that.imagens,_that.legenda,_that.likesCount,_that.commentsCount,_that.createdAt,_that.privado,_that.userName,_that.userAvatar,_that.missionName,_that.isLiked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'missao_id')  String? missaoId,  List<String> imagens,  String legenda, @JsonKey(name: 'n_curtidas')  int likesCount, @JsonKey(name: 'n_comentarios')  int commentsCount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'privado')  bool privado,  String? userName,  String? userAvatar,  String? missionName,  bool isLiked)?  $default,) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.id,_that.userId,_that.missaoId,_that.imagens,_that.legenda,_that.likesCount,_that.commentsCount,_that.createdAt,_that.privado,_that.userName,_that.userAvatar,_that.missionName,_that.isLiked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostModel extends PostModel {
  const _PostModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'missao_id') this.missaoId, required final  List<String> imagens, required this.legenda, @JsonKey(name: 'n_curtidas') this.likesCount = 0, @JsonKey(name: 'n_comentarios') this.commentsCount = 0, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'privado') this.privado = false, this.userName, this.userAvatar, this.missionName, this.isLiked = false}): _imagens = imagens,super._();
  factory _PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'missao_id') final  String? missaoId;
 final  List<String> _imagens;
@override List<String> get imagens {
  if (_imagens is EqualUnmodifiableListView) return _imagens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagens);
}

@override final  String legenda;
@override@JsonKey(name: 'n_curtidas') final  int likesCount;
@override@JsonKey(name: 'n_comentarios') final  int commentsCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'privado') final  bool privado;
// Joined data
@override final  String? userName;
@override final  String? userAvatar;
@override final  String? missionName;
@override@JsonKey() final  bool isLiked;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostModelCopyWith<_PostModel> get copyWith => __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.missaoId, missaoId) || other.missaoId == missaoId)&&const DeepCollectionEquality().equals(other._imagens, _imagens)&&(identical(other.legenda, legenda) || other.legenda == legenda)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.privado, privado) || other.privado == privado)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,missaoId,const DeepCollectionEquality().hash(_imagens),legenda,likesCount,commentsCount,createdAt,privado,userName,userAvatar,missionName,isLiked);

@override
String toString() {
  return 'PostModel(id: $id, userId: $userId, missaoId: $missaoId, imagens: $imagens, legenda: $legenda, likesCount: $likesCount, commentsCount: $commentsCount, createdAt: $createdAt, privado: $privado, userName: $userName, userAvatar: $userAvatar, missionName: $missionName, isLiked: $isLiked)';
}


}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res> implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(_PostModel value, $Res Function(_PostModel) _then) = __$PostModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'missao_id') String? missaoId, List<String> imagens, String legenda,@JsonKey(name: 'n_curtidas') int likesCount,@JsonKey(name: 'n_comentarios') int commentsCount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'privado') bool privado, String? userName, String? userAvatar, String? missionName, bool isLiked
});




}
/// @nodoc
class __$PostModelCopyWithImpl<$Res>
    implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? missaoId = freezed,Object? imagens = null,Object? legenda = null,Object? likesCount = null,Object? commentsCount = null,Object? createdAt = null,Object? privado = null,Object? userName = freezed,Object? userAvatar = freezed,Object? missionName = freezed,Object? isLiked = null,}) {
  return _then(_PostModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,missaoId: freezed == missaoId ? _self.missaoId : missaoId // ignore: cast_nullable_to_non_nullable
as String?,imagens: null == imagens ? _self._imagens : imagens // ignore: cast_nullable_to_non_nullable
as List<String>,legenda: null == legenda ? _self.legenda : legenda // ignore: cast_nullable_to_non_nullable
as String,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,privado: null == privado ? _self.privado : privado // ignore: cast_nullable_to_non_nullable
as bool,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
