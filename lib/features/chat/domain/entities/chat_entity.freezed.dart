// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatEntity {

 String get id; String get title; String get subtitle; String? get imageUrl; DateTime? get startDate; DateTime? get endDate; int get unreadCount; int get memberCount;
/// Create a copy of ChatEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEntityCopyWith<ChatEntity> get copyWith => _$ChatEntityCopyWithImpl<ChatEntity>(this as ChatEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,imageUrl,startDate,endDate,unreadCount,memberCount);

@override
String toString() {
  return 'ChatEntity(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, startDate: $startDate, endDate: $endDate, unreadCount: $unreadCount, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class $ChatEntityCopyWith<$Res>  {
  factory $ChatEntityCopyWith(ChatEntity value, $Res Function(ChatEntity) _then) = _$ChatEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, String? imageUrl, DateTime? startDate, DateTime? endDate, int unreadCount, int memberCount
});




}
/// @nodoc
class _$ChatEntityCopyWithImpl<$Res>
    implements $ChatEntityCopyWith<$Res> {
  _$ChatEntityCopyWithImpl(this._self, this._then);

  final ChatEntity _self;
  final $Res Function(ChatEntity) _then;

/// Create a copy of ChatEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? imageUrl = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? unreadCount = null,Object? memberCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatEntity].
extension ChatEntityPatterns on ChatEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String? imageUrl,  DateTime? startDate,  DateTime? endDate,  int unreadCount,  int memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatEntity() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.startDate,_that.endDate,_that.unreadCount,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String? imageUrl,  DateTime? startDate,  DateTime? endDate,  int unreadCount,  int memberCount)  $default,) {final _that = this;
switch (_that) {
case _ChatEntity():
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.startDate,_that.endDate,_that.unreadCount,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  String? imageUrl,  DateTime? startDate,  DateTime? endDate,  int unreadCount,  int memberCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatEntity() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.imageUrl,_that.startDate,_that.endDate,_that.unreadCount,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _ChatEntity implements ChatEntity {
  const _ChatEntity({required this.id, required this.title, required this.subtitle, this.imageUrl, this.startDate, this.endDate, this.unreadCount = 0, this.memberCount = 0});
  

@override final  String id;
@override final  String title;
@override final  String subtitle;
@override final  String? imageUrl;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  int memberCount;

/// Create a copy of ChatEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatEntityCopyWith<_ChatEntity> get copyWith => __$ChatEntityCopyWithImpl<_ChatEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,imageUrl,startDate,endDate,unreadCount,memberCount);

@override
String toString() {
  return 'ChatEntity(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, startDate: $startDate, endDate: $endDate, unreadCount: $unreadCount, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$ChatEntityCopyWith<$Res> implements $ChatEntityCopyWith<$Res> {
  factory _$ChatEntityCopyWith(_ChatEntity value, $Res Function(_ChatEntity) _then) = __$ChatEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, String? imageUrl, DateTime? startDate, DateTime? endDate, int unreadCount, int memberCount
});




}
/// @nodoc
class __$ChatEntityCopyWithImpl<$Res>
    implements _$ChatEntityCopyWith<$Res> {
  __$ChatEntityCopyWithImpl(this._self, this._then);

  final _ChatEntity _self;
  final $Res Function(_ChatEntity) _then;

/// Create a copy of ChatEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? imageUrl = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? unreadCount = null,Object? memberCount = null,}) {
  return _then(_ChatEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GuideEntity {

 String get id; String get name; String get role; String? get avatarUrl;
/// Create a copy of GuideEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuideEntityCopyWith<GuideEntity> get copyWith => _$GuideEntityCopyWithImpl<GuideEntity>(this as GuideEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuideEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,avatarUrl);

@override
String toString() {
  return 'GuideEntity(id: $id, name: $name, role: $role, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $GuideEntityCopyWith<$Res>  {
  factory $GuideEntityCopyWith(GuideEntity value, $Res Function(GuideEntity) _then) = _$GuideEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, String? avatarUrl
});




}
/// @nodoc
class _$GuideEntityCopyWithImpl<$Res>
    implements $GuideEntityCopyWith<$Res> {
  _$GuideEntityCopyWithImpl(this._self, this._then);

  final GuideEntity _self;
  final $Res Function(GuideEntity) _then;

/// Create a copy of GuideEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuideEntity].
extension GuideEntityPatterns on GuideEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuideEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuideEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuideEntity value)  $default,){
final _that = this;
switch (_that) {
case _GuideEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuideEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GuideEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuideEntity() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _GuideEntity():
return $default(_that.id,_that.name,_that.role,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _GuideEntity() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _GuideEntity implements GuideEntity {
  const _GuideEntity({required this.id, required this.name, required this.role, this.avatarUrl});
  

@override final  String id;
@override final  String name;
@override final  String role;
@override final  String? avatarUrl;

/// Create a copy of GuideEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuideEntityCopyWith<_GuideEntity> get copyWith => __$GuideEntityCopyWithImpl<_GuideEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuideEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,avatarUrl);

@override
String toString() {
  return 'GuideEntity(id: $id, name: $name, role: $role, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$GuideEntityCopyWith<$Res> implements $GuideEntityCopyWith<$Res> {
  factory _$GuideEntityCopyWith(_GuideEntity value, $Res Function(_GuideEntity) _then) = __$GuideEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, String? avatarUrl
});




}
/// @nodoc
class __$GuideEntityCopyWithImpl<$Res>
    implements _$GuideEntityCopyWith<$Res> {
  __$GuideEntityCopyWithImpl(this._self, this._then);

  final _GuideEntity _self;
  final $Res Function(_GuideEntity) _then;

/// Create a copy of GuideEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? avatarUrl = freezed,}) {
  return _then(_GuideEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ChatData {

 ChatEntity? get currentMission; List<GuideEntity> get guides; List<ChatEntity> get history; Map<String, String> get lastMessages; Map<String, DateTime> get lastMessageTimes;
/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDataCopyWith<ChatData> get copyWith => _$ChatDataCopyWithImpl<ChatData>(this as ChatData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatData&&(identical(other.currentMission, currentMission) || other.currentMission == currentMission)&&const DeepCollectionEquality().equals(other.guides, guides)&&const DeepCollectionEquality().equals(other.history, history)&&const DeepCollectionEquality().equals(other.lastMessages, lastMessages)&&const DeepCollectionEquality().equals(other.lastMessageTimes, lastMessageTimes));
}


@override
int get hashCode => Object.hash(runtimeType,currentMission,const DeepCollectionEquality().hash(guides),const DeepCollectionEquality().hash(history),const DeepCollectionEquality().hash(lastMessages),const DeepCollectionEquality().hash(lastMessageTimes));

@override
String toString() {
  return 'ChatData(currentMission: $currentMission, guides: $guides, history: $history, lastMessages: $lastMessages, lastMessageTimes: $lastMessageTimes)';
}


}

/// @nodoc
abstract mixin class $ChatDataCopyWith<$Res>  {
  factory $ChatDataCopyWith(ChatData value, $Res Function(ChatData) _then) = _$ChatDataCopyWithImpl;
@useResult
$Res call({
 ChatEntity? currentMission, List<GuideEntity> guides, List<ChatEntity> history, Map<String, String> lastMessages, Map<String, DateTime> lastMessageTimes
});


$ChatEntityCopyWith<$Res>? get currentMission;

}
/// @nodoc
class _$ChatDataCopyWithImpl<$Res>
    implements $ChatDataCopyWith<$Res> {
  _$ChatDataCopyWithImpl(this._self, this._then);

  final ChatData _self;
  final $Res Function(ChatData) _then;

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentMission = freezed,Object? guides = null,Object? history = null,Object? lastMessages = null,Object? lastMessageTimes = null,}) {
  return _then(_self.copyWith(
currentMission: freezed == currentMission ? _self.currentMission : currentMission // ignore: cast_nullable_to_non_nullable
as ChatEntity?,guides: null == guides ? _self.guides : guides // ignore: cast_nullable_to_non_nullable
as List<GuideEntity>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<ChatEntity>,lastMessages: null == lastMessages ? _self.lastMessages : lastMessages // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastMessageTimes: null == lastMessageTimes ? _self.lastMessageTimes : lastMessageTimes // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,
  ));
}
/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatEntityCopyWith<$Res>? get currentMission {
    if (_self.currentMission == null) {
    return null;
  }

  return $ChatEntityCopyWith<$Res>(_self.currentMission!, (value) {
    return _then(_self.copyWith(currentMission: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatData].
extension ChatDataPatterns on ChatData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatData value)  $default,){
final _that = this;
switch (_that) {
case _ChatData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatData value)?  $default,){
final _that = this;
switch (_that) {
case _ChatData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatEntity? currentMission,  List<GuideEntity> guides,  List<ChatEntity> history,  Map<String, String> lastMessages,  Map<String, DateTime> lastMessageTimes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatData() when $default != null:
return $default(_that.currentMission,_that.guides,_that.history,_that.lastMessages,_that.lastMessageTimes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatEntity? currentMission,  List<GuideEntity> guides,  List<ChatEntity> history,  Map<String, String> lastMessages,  Map<String, DateTime> lastMessageTimes)  $default,) {final _that = this;
switch (_that) {
case _ChatData():
return $default(_that.currentMission,_that.guides,_that.history,_that.lastMessages,_that.lastMessageTimes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatEntity? currentMission,  List<GuideEntity> guides,  List<ChatEntity> history,  Map<String, String> lastMessages,  Map<String, DateTime> lastMessageTimes)?  $default,) {final _that = this;
switch (_that) {
case _ChatData() when $default != null:
return $default(_that.currentMission,_that.guides,_that.history,_that.lastMessages,_that.lastMessageTimes);case _:
  return null;

}
}

}

/// @nodoc


class _ChatData implements ChatData {
  const _ChatData({this.currentMission, final  List<GuideEntity> guides = const [], final  List<ChatEntity> history = const [], final  Map<String, String> lastMessages = const {}, final  Map<String, DateTime> lastMessageTimes = const {}}): _guides = guides,_history = history,_lastMessages = lastMessages,_lastMessageTimes = lastMessageTimes;
  

@override final  ChatEntity? currentMission;
 final  List<GuideEntity> _guides;
@override@JsonKey() List<GuideEntity> get guides {
  if (_guides is EqualUnmodifiableListView) return _guides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guides);
}

 final  List<ChatEntity> _history;
@override@JsonKey() List<ChatEntity> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  Map<String, String> _lastMessages;
@override@JsonKey() Map<String, String> get lastMessages {
  if (_lastMessages is EqualUnmodifiableMapView) return _lastMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastMessages);
}

 final  Map<String, DateTime> _lastMessageTimes;
@override@JsonKey() Map<String, DateTime> get lastMessageTimes {
  if (_lastMessageTimes is EqualUnmodifiableMapView) return _lastMessageTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastMessageTimes);
}


/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDataCopyWith<_ChatData> get copyWith => __$ChatDataCopyWithImpl<_ChatData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatData&&(identical(other.currentMission, currentMission) || other.currentMission == currentMission)&&const DeepCollectionEquality().equals(other._guides, _guides)&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._lastMessages, _lastMessages)&&const DeepCollectionEquality().equals(other._lastMessageTimes, _lastMessageTimes));
}


@override
int get hashCode => Object.hash(runtimeType,currentMission,const DeepCollectionEquality().hash(_guides),const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_lastMessages),const DeepCollectionEquality().hash(_lastMessageTimes));

@override
String toString() {
  return 'ChatData(currentMission: $currentMission, guides: $guides, history: $history, lastMessages: $lastMessages, lastMessageTimes: $lastMessageTimes)';
}


}

/// @nodoc
abstract mixin class _$ChatDataCopyWith<$Res> implements $ChatDataCopyWith<$Res> {
  factory _$ChatDataCopyWith(_ChatData value, $Res Function(_ChatData) _then) = __$ChatDataCopyWithImpl;
@override @useResult
$Res call({
 ChatEntity? currentMission, List<GuideEntity> guides, List<ChatEntity> history, Map<String, String> lastMessages, Map<String, DateTime> lastMessageTimes
});


@override $ChatEntityCopyWith<$Res>? get currentMission;

}
/// @nodoc
class __$ChatDataCopyWithImpl<$Res>
    implements _$ChatDataCopyWith<$Res> {
  __$ChatDataCopyWithImpl(this._self, this._then);

  final _ChatData _self;
  final $Res Function(_ChatData) _then;

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentMission = freezed,Object? guides = null,Object? history = null,Object? lastMessages = null,Object? lastMessageTimes = null,}) {
  return _then(_ChatData(
currentMission: freezed == currentMission ? _self.currentMission : currentMission // ignore: cast_nullable_to_non_nullable
as ChatEntity?,guides: null == guides ? _self._guides : guides // ignore: cast_nullable_to_non_nullable
as List<GuideEntity>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<ChatEntity>,lastMessages: null == lastMessages ? _self._lastMessages : lastMessages // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastMessageTimes: null == lastMessageTimes ? _self._lastMessageTimes : lastMessageTimes // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,
  ));
}

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatEntityCopyWith<$Res>? get currentMission {
    if (_self.currentMission == null) {
    return null;
  }

  return $ChatEntityCopyWith<$Res>(_self.currentMission!, (value) {
    return _then(_self.copyWith(currentMission: value));
  });
}
}

/// @nodoc
mixin _$GroupMemberEntity {

 String get id; String get name; String get role; bool get isGuide; bool get isMe; String? get avatarUrl; ConnectionStatus get connectionStatus;
/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMemberEntityCopyWith<GroupMemberEntity> get copyWith => _$GroupMemberEntityCopyWithImpl<GroupMemberEntity>(this as GroupMemberEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMemberEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.isGuide, isGuide) || other.isGuide == isGuide)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,isGuide,isMe,avatarUrl,connectionStatus);

@override
String toString() {
  return 'GroupMemberEntity(id: $id, name: $name, role: $role, isGuide: $isGuide, isMe: $isMe, avatarUrl: $avatarUrl, connectionStatus: $connectionStatus)';
}


}

/// @nodoc
abstract mixin class $GroupMemberEntityCopyWith<$Res>  {
  factory $GroupMemberEntityCopyWith(GroupMemberEntity value, $Res Function(GroupMemberEntity) _then) = _$GroupMemberEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, bool isGuide, bool isMe, String? avatarUrl, ConnectionStatus connectionStatus
});




}
/// @nodoc
class _$GroupMemberEntityCopyWithImpl<$Res>
    implements $GroupMemberEntityCopyWith<$Res> {
  _$GroupMemberEntityCopyWithImpl(this._self, this._then);

  final GroupMemberEntity _self;
  final $Res Function(GroupMemberEntity) _then;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? isGuide = null,Object? isMe = null,Object? avatarUrl = freezed,Object? connectionStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isGuide: null == isGuide ? _self.isGuide : isGuide // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupMemberEntity].
extension GroupMemberEntityPatterns on GroupMemberEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMemberEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMemberEntity value)  $default,){
final _that = this;
switch (_that) {
case _GroupMemberEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMemberEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  bool isGuide,  bool isMe,  String? avatarUrl,  ConnectionStatus connectionStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.isGuide,_that.isMe,_that.avatarUrl,_that.connectionStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  bool isGuide,  bool isMe,  String? avatarUrl,  ConnectionStatus connectionStatus)  $default,) {final _that = this;
switch (_that) {
case _GroupMemberEntity():
return $default(_that.id,_that.name,_that.role,_that.isGuide,_that.isMe,_that.avatarUrl,_that.connectionStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  bool isGuide,  bool isMe,  String? avatarUrl,  ConnectionStatus connectionStatus)?  $default,) {final _that = this;
switch (_that) {
case _GroupMemberEntity() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.isGuide,_that.isMe,_that.avatarUrl,_that.connectionStatus);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMemberEntity implements GroupMemberEntity {
  const _GroupMemberEntity({required this.id, required this.name, required this.role, required this.isGuide, this.isMe = false, this.avatarUrl, this.connectionStatus = ConnectionStatus.none});
  

@override final  String id;
@override final  String name;
@override final  String role;
@override final  bool isGuide;
@override@JsonKey() final  bool isMe;
@override final  String? avatarUrl;
@override@JsonKey() final  ConnectionStatus connectionStatus;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMemberEntityCopyWith<_GroupMemberEntity> get copyWith => __$GroupMemberEntityCopyWithImpl<_GroupMemberEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMemberEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.isGuide, isGuide) || other.isGuide == isGuide)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role,isGuide,isMe,avatarUrl,connectionStatus);

@override
String toString() {
  return 'GroupMemberEntity(id: $id, name: $name, role: $role, isGuide: $isGuide, isMe: $isMe, avatarUrl: $avatarUrl, connectionStatus: $connectionStatus)';
}


}

/// @nodoc
abstract mixin class _$GroupMemberEntityCopyWith<$Res> implements $GroupMemberEntityCopyWith<$Res> {
  factory _$GroupMemberEntityCopyWith(_GroupMemberEntity value, $Res Function(_GroupMemberEntity) _then) = __$GroupMemberEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, bool isGuide, bool isMe, String? avatarUrl, ConnectionStatus connectionStatus
});




}
/// @nodoc
class __$GroupMemberEntityCopyWithImpl<$Res>
    implements _$GroupMemberEntityCopyWith<$Res> {
  __$GroupMemberEntityCopyWithImpl(this._self, this._then);

  final _GroupMemberEntity _self;
  final $Res Function(_GroupMemberEntity) _then;

/// Create a copy of GroupMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? isGuide = null,Object? isMe = null,Object? avatarUrl = freezed,Object? connectionStatus = null,}) {
  return _then(_GroupMemberEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isGuide: null == isGuide ? _self.isGuide : isGuide // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,
  ));
}


}

/// @nodoc
mixin _$GroupDetailEntity {

 List<GroupMemberEntity> get members; List<String> get mediaUrls;
/// Create a copy of GroupDetailEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupDetailEntityCopyWith<GroupDetailEntity> get copyWith => _$GroupDetailEntityCopyWithImpl<GroupDetailEntity>(this as GroupDetailEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupDetailEntity&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(mediaUrls));

@override
String toString() {
  return 'GroupDetailEntity(members: $members, mediaUrls: $mediaUrls)';
}


}

/// @nodoc
abstract mixin class $GroupDetailEntityCopyWith<$Res>  {
  factory $GroupDetailEntityCopyWith(GroupDetailEntity value, $Res Function(GroupDetailEntity) _then) = _$GroupDetailEntityCopyWithImpl;
@useResult
$Res call({
 List<GroupMemberEntity> members, List<String> mediaUrls
});




}
/// @nodoc
class _$GroupDetailEntityCopyWithImpl<$Res>
    implements $GroupDetailEntityCopyWith<$Res> {
  _$GroupDetailEntityCopyWithImpl(this._self, this._then);

  final GroupDetailEntity _self;
  final $Res Function(GroupDetailEntity) _then;

/// Create a copy of GroupDetailEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? mediaUrls = null,}) {
  return _then(_self.copyWith(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<GroupMemberEntity>,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupDetailEntity].
extension GroupDetailEntityPatterns on GroupDetailEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupDetailEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupDetailEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupDetailEntity value)  $default,){
final _that = this;
switch (_that) {
case _GroupDetailEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupDetailEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GroupDetailEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GroupMemberEntity> members,  List<String> mediaUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupDetailEntity() when $default != null:
return $default(_that.members,_that.mediaUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GroupMemberEntity> members,  List<String> mediaUrls)  $default,) {final _that = this;
switch (_that) {
case _GroupDetailEntity():
return $default(_that.members,_that.mediaUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GroupMemberEntity> members,  List<String> mediaUrls)?  $default,) {final _that = this;
switch (_that) {
case _GroupDetailEntity() when $default != null:
return $default(_that.members,_that.mediaUrls);case _:
  return null;

}
}

}

/// @nodoc


class _GroupDetailEntity implements GroupDetailEntity {
  const _GroupDetailEntity({required final  List<GroupMemberEntity> members, required final  List<String> mediaUrls}): _members = members,_mediaUrls = mediaUrls;
  

 final  List<GroupMemberEntity> _members;
@override List<GroupMemberEntity> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<String> _mediaUrls;
@override List<String> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}


/// Create a copy of GroupDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupDetailEntityCopyWith<_GroupDetailEntity> get copyWith => __$GroupDetailEntityCopyWithImpl<_GroupDetailEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupDetailEntity&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_mediaUrls));

@override
String toString() {
  return 'GroupDetailEntity(members: $members, mediaUrls: $mediaUrls)';
}


}

/// @nodoc
abstract mixin class _$GroupDetailEntityCopyWith<$Res> implements $GroupDetailEntityCopyWith<$Res> {
  factory _$GroupDetailEntityCopyWith(_GroupDetailEntity value, $Res Function(_GroupDetailEntity) _then) = __$GroupDetailEntityCopyWithImpl;
@override @useResult
$Res call({
 List<GroupMemberEntity> members, List<String> mediaUrls
});




}
/// @nodoc
class __$GroupDetailEntityCopyWithImpl<$Res>
    implements _$GroupDetailEntityCopyWith<$Res> {
  __$GroupDetailEntityCopyWithImpl(this._self, this._then);

  final _GroupDetailEntity _self;
  final $Res Function(_GroupDetailEntity) _then;

/// Create a copy of GroupDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? mediaUrls = null,}) {
  return _then(_GroupDetailEntity(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<GroupMemberEntity>,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
