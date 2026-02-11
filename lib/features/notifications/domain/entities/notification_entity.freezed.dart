// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationEntity {

 String get id; String get userName; String? get userAvatar; NotificationType get type; String? get postImage; String? get postId; String? get solicitacaoUserId; String? get docId; String? get postOwnerId; String get message; DateTime get createdAt; bool get isRead;
/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationEntityCopyWith<NotificationEntity> get copyWith => _$NotificationEntityCopyWithImpl<NotificationEntity>(this as NotificationEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.postImage, postImage) || other.postImage == postImage)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.solicitacaoUserId, solicitacaoUserId) || other.solicitacaoUserId == solicitacaoUserId)&&(identical(other.docId, docId) || other.docId == docId)&&(identical(other.postOwnerId, postOwnerId) || other.postOwnerId == postOwnerId)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}


@override
int get hashCode => Object.hash(runtimeType,id,userName,userAvatar,type,postImage,postId,solicitacaoUserId,docId,postOwnerId,message,createdAt,isRead);

@override
String toString() {
  return 'NotificationEntity(id: $id, userName: $userName, userAvatar: $userAvatar, type: $type, postImage: $postImage, postId: $postId, solicitacaoUserId: $solicitacaoUserId, docId: $docId, postOwnerId: $postOwnerId, message: $message, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $NotificationEntityCopyWith<$Res>  {
  factory $NotificationEntityCopyWith(NotificationEntity value, $Res Function(NotificationEntity) _then) = _$NotificationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String userName, String? userAvatar, NotificationType type, String? postImage, String? postId, String? solicitacaoUserId, String? docId, String? postOwnerId, String message, DateTime createdAt, bool isRead
});




}
/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._self, this._then);

  final NotificationEntity _self;
  final $Res Function(NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userName = null,Object? userAvatar = freezed,Object? type = null,Object? postImage = freezed,Object? postId = freezed,Object? solicitacaoUserId = freezed,Object? docId = freezed,Object? postOwnerId = freezed,Object? message = null,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,postImage: freezed == postImage ? _self.postImage : postImage // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoUserId: freezed == solicitacaoUserId ? _self.solicitacaoUserId : solicitacaoUserId // ignore: cast_nullable_to_non_nullable
as String?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as String?,postOwnerId: freezed == postOwnerId ? _self.postOwnerId : postOwnerId // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationEntity].
extension NotificationEntityPatterns on NotificationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationEntity value)  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userName,  String? userAvatar,  NotificationType type,  String? postImage,  String? postId,  String? solicitacaoUserId,  String? docId,  String? postOwnerId,  String message,  DateTime createdAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.userName,_that.userAvatar,_that.type,_that.postImage,_that.postId,_that.solicitacaoUserId,_that.docId,_that.postOwnerId,_that.message,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userName,  String? userAvatar,  NotificationType type,  String? postImage,  String? postId,  String? solicitacaoUserId,  String? docId,  String? postOwnerId,  String message,  DateTime createdAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity():
return $default(_that.id,_that.userName,_that.userAvatar,_that.type,_that.postImage,_that.postId,_that.solicitacaoUserId,_that.docId,_that.postOwnerId,_that.message,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userName,  String? userAvatar,  NotificationType type,  String? postImage,  String? postId,  String? solicitacaoUserId,  String? docId,  String? postOwnerId,  String message,  DateTime createdAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.userName,_that.userAvatar,_that.type,_that.postImage,_that.postId,_that.solicitacaoUserId,_that.docId,_that.postOwnerId,_that.message,_that.createdAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationEntity implements NotificationEntity {
  const _NotificationEntity({required this.id, required this.userName, this.userAvatar, required this.type, this.postImage, this.postId, this.solicitacaoUserId, this.docId, this.postOwnerId, required this.message, required this.createdAt, this.isRead = false});
  

@override final  String id;
@override final  String userName;
@override final  String? userAvatar;
@override final  NotificationType type;
@override final  String? postImage;
@override final  String? postId;
@override final  String? solicitacaoUserId;
@override final  String? docId;
@override final  String? postOwnerId;
@override final  String message;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isRead;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationEntityCopyWith<_NotificationEntity> get copyWith => __$NotificationEntityCopyWithImpl<_NotificationEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.postImage, postImage) || other.postImage == postImage)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.solicitacaoUserId, solicitacaoUserId) || other.solicitacaoUserId == solicitacaoUserId)&&(identical(other.docId, docId) || other.docId == docId)&&(identical(other.postOwnerId, postOwnerId) || other.postOwnerId == postOwnerId)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}


@override
int get hashCode => Object.hash(runtimeType,id,userName,userAvatar,type,postImage,postId,solicitacaoUserId,docId,postOwnerId,message,createdAt,isRead);

@override
String toString() {
  return 'NotificationEntity(id: $id, userName: $userName, userAvatar: $userAvatar, type: $type, postImage: $postImage, postId: $postId, solicitacaoUserId: $solicitacaoUserId, docId: $docId, postOwnerId: $postOwnerId, message: $message, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$NotificationEntityCopyWith<$Res> implements $NotificationEntityCopyWith<$Res> {
  factory _$NotificationEntityCopyWith(_NotificationEntity value, $Res Function(_NotificationEntity) _then) = __$NotificationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userName, String? userAvatar, NotificationType type, String? postImage, String? postId, String? solicitacaoUserId, String? docId, String? postOwnerId, String message, DateTime createdAt, bool isRead
});




}
/// @nodoc
class __$NotificationEntityCopyWithImpl<$Res>
    implements _$NotificationEntityCopyWith<$Res> {
  __$NotificationEntityCopyWithImpl(this._self, this._then);

  final _NotificationEntity _self;
  final $Res Function(_NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userName = null,Object? userAvatar = freezed,Object? type = null,Object? postImage = freezed,Object? postId = freezed,Object? solicitacaoUserId = freezed,Object? docId = freezed,Object? postOwnerId = freezed,Object? message = null,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_NotificationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,postImage: freezed == postImage ? _self.postImage : postImage // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,solicitacaoUserId: freezed == solicitacaoUserId ? _self.solicitacaoUserId : solicitacaoUserId // ignore: cast_nullable_to_non_nullable
as String?,docId: freezed == docId ? _self.docId : docId // ignore: cast_nullable_to_non_nullable
as String?,postOwnerId: freezed == postOwnerId ? _self.postOwnerId : postOwnerId // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
