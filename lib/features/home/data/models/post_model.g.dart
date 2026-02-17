// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  missaoId: json['missao_id'] as String?,
  imagens: (json['imagens'] as List<dynamic>).map((e) => e as String).toList(),
  legenda: json['legenda'] as String,
  likesCount: (json['n_curtidas'] as num?)?.toInt() ?? 0,
  commentsCount: (json['n_comentarios'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  privado: json['privado'] as bool? ?? false,
  userName: json['userName'] as String?,
  userAvatar: json['userAvatar'] as String?,
  missionName: json['missionName'] as String?,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'missao_id': instance.missaoId,
      'imagens': instance.imagens,
      'legenda': instance.legenda,
      'n_curtidas': instance.likesCount,
      'n_comentarios': instance.commentsCount,
      'created_at': instance.createdAt.toIso8601String(),
      'privado': instance.privado,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'missionName': instance.missionName,
      'isLiked': instance.isLiked,
    };
