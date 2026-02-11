// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageEntity {

 String get id; String get text; DateTime get timestamp; MessageType get type; String? get userName; String? get userAvatarUrl; String? get guideRole; String? get attachmentUrl; MessageEntity? get repliedToMessage; bool get isEdited; bool get isDeleted;
/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageEntityCopyWith<MessageEntity> get copyWith => _$MessageEntityCopyWithImpl<MessageEntity>(this as MessageEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.guideRole, guideRole) || other.guideRole == guideRole)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.repliedToMessage, repliedToMessage) || other.repliedToMessage == repliedToMessage)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,timestamp,type,userName,userAvatarUrl,guideRole,attachmentUrl,repliedToMessage,isEdited,isDeleted);

@override
String toString() {
  return 'MessageEntity(id: $id, text: $text, timestamp: $timestamp, type: $type, userName: $userName, userAvatarUrl: $userAvatarUrl, guideRole: $guideRole, attachmentUrl: $attachmentUrl, repliedToMessage: $repliedToMessage, isEdited: $isEdited, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $MessageEntityCopyWith<$Res>  {
  factory $MessageEntityCopyWith(MessageEntity value, $Res Function(MessageEntity) _then) = _$MessageEntityCopyWithImpl;
@useResult
$Res call({
 String id, String text, DateTime timestamp, MessageType type, String? userName, String? userAvatarUrl, String? guideRole, String? attachmentUrl, MessageEntity? repliedToMessage, bool isEdited, bool isDeleted
});


$MessageEntityCopyWith<$Res>? get repliedToMessage;

}
/// @nodoc
class _$MessageEntityCopyWithImpl<$Res>
    implements $MessageEntityCopyWith<$Res> {
  _$MessageEntityCopyWithImpl(this._self, this._then);

  final MessageEntity _self;
  final $Res Function(MessageEntity) _then;

/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? timestamp = null,Object? type = null,Object? userName = freezed,Object? userAvatarUrl = freezed,Object? guideRole = freezed,Object? attachmentUrl = freezed,Object? repliedToMessage = freezed,Object? isEdited = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,guideRole: freezed == guideRole ? _self.guideRole : guideRole // ignore: cast_nullable_to_non_nullable
as String?,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,repliedToMessage: freezed == repliedToMessage ? _self.repliedToMessage : repliedToMessage // ignore: cast_nullable_to_non_nullable
as MessageEntity?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageEntityCopyWith<$Res>? get repliedToMessage {
    if (_self.repliedToMessage == null) {
    return null;
  }

  return $MessageEntityCopyWith<$Res>(_self.repliedToMessage!, (value) {
    return _then(_self.copyWith(repliedToMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageEntity].
extension MessageEntityPatterns on MessageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageEntity value)  $default,){
final _that = this;
switch (_that) {
case _MessageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MessageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  DateTime timestamp,  MessageType type,  String? userName,  String? userAvatarUrl,  String? guideRole,  String? attachmentUrl,  MessageEntity? repliedToMessage,  bool isEdited,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageEntity() when $default != null:
return $default(_that.id,_that.text,_that.timestamp,_that.type,_that.userName,_that.userAvatarUrl,_that.guideRole,_that.attachmentUrl,_that.repliedToMessage,_that.isEdited,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  DateTime timestamp,  MessageType type,  String? userName,  String? userAvatarUrl,  String? guideRole,  String? attachmentUrl,  MessageEntity? repliedToMessage,  bool isEdited,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _MessageEntity():
return $default(_that.id,_that.text,_that.timestamp,_that.type,_that.userName,_that.userAvatarUrl,_that.guideRole,_that.attachmentUrl,_that.repliedToMessage,_that.isEdited,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  DateTime timestamp,  MessageType type,  String? userName,  String? userAvatarUrl,  String? guideRole,  String? attachmentUrl,  MessageEntity? repliedToMessage,  bool isEdited,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _MessageEntity() when $default != null:
return $default(_that.id,_that.text,_that.timestamp,_that.type,_that.userName,_that.userAvatarUrl,_that.guideRole,_that.attachmentUrl,_that.repliedToMessage,_that.isEdited,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc


class _MessageEntity extends MessageEntity {
  const _MessageEntity({required this.id, required this.text, required this.timestamp, required this.type, this.userName, this.userAvatarUrl, this.guideRole, this.attachmentUrl, this.repliedToMessage, required this.isEdited, required this.isDeleted}): super._();
  

@override final  String id;
@override final  String text;
@override final  DateTime timestamp;
@override final  MessageType type;
@override final  String? userName;
@override final  String? userAvatarUrl;
@override final  String? guideRole;
@override final  String? attachmentUrl;
@override final  MessageEntity? repliedToMessage;
@override final  bool isEdited;
@override final  bool isDeleted;

/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageEntityCopyWith<_MessageEntity> get copyWith => __$MessageEntityCopyWithImpl<_MessageEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.guideRole, guideRole) || other.guideRole == guideRole)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.repliedToMessage, repliedToMessage) || other.repliedToMessage == repliedToMessage)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,timestamp,type,userName,userAvatarUrl,guideRole,attachmentUrl,repliedToMessage,isEdited,isDeleted);

@override
String toString() {
  return 'MessageEntity(id: $id, text: $text, timestamp: $timestamp, type: $type, userName: $userName, userAvatarUrl: $userAvatarUrl, guideRole: $guideRole, attachmentUrl: $attachmentUrl, repliedToMessage: $repliedToMessage, isEdited: $isEdited, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$MessageEntityCopyWith<$Res> implements $MessageEntityCopyWith<$Res> {
  factory _$MessageEntityCopyWith(_MessageEntity value, $Res Function(_MessageEntity) _then) = __$MessageEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime timestamp, MessageType type, String? userName, String? userAvatarUrl, String? guideRole, String? attachmentUrl, MessageEntity? repliedToMessage, bool isEdited, bool isDeleted
});


@override $MessageEntityCopyWith<$Res>? get repliedToMessage;

}
/// @nodoc
class __$MessageEntityCopyWithImpl<$Res>
    implements _$MessageEntityCopyWith<$Res> {
  __$MessageEntityCopyWithImpl(this._self, this._then);

  final _MessageEntity _self;
  final $Res Function(_MessageEntity) _then;

/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? timestamp = null,Object? type = null,Object? userName = freezed,Object? userAvatarUrl = freezed,Object? guideRole = freezed,Object? attachmentUrl = freezed,Object? repliedToMessage = freezed,Object? isEdited = null,Object? isDeleted = null,}) {
  return _then(_MessageEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,guideRole: freezed == guideRole ? _self.guideRole : guideRole // ignore: cast_nullable_to_non_nullable
as String?,attachmentUrl: freezed == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String?,repliedToMessage: freezed == repliedToMessage ? _self.repliedToMessage : repliedToMessage // ignore: cast_nullable_to_non_nullable
as MessageEntity?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageEntityCopyWith<$Res>? get repliedToMessage {
    if (_self.repliedToMessage == null) {
    return null;
  }

  return $MessageEntityCopyWith<$Res>(_self.repliedToMessage!, (value) {
    return _then(_self.copyWith(repliedToMessage: value));
  });
}
}

// dart format on
