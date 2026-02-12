// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      text: json['comentario'] as String,
      parentId: json['id_comentario'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'post_id': instance.postId,
      'comentario': instance.text,
      'id_comentario': instance.parentId,
      'created_at': instance.createdAt.toIso8601String(),
    };
