// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mensagem: json['mensagem'] as String?,
      lido: json['lido'] as bool?,
      userId: json['user_id'] as String?,
      assunto: json['assunto'] as String?,
      missionId: json['missao_id'] as String?,
      postId: json['post_id'] as String?,
      solicitacaoUserId: json['solicitacao_user_id'] as String?,
      solicitacaoRespondida: json['solicitacaorespondida'] as bool?,
      docId: json['doc_id'] as String?,
      titulo: json['titulo'] as String?,
      icone: json['icone'] as String?,
      grupoId: json['grupo_id'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'mensagem': instance.mensagem,
      'lido': instance.lido,
      'user_id': instance.userId,
      'assunto': instance.assunto,
      'missao_id': instance.missionId,
      'post_id': instance.postId,
      'solicitacao_user_id': instance.solicitacaoUserId,
      'solicitacaorespondida': instance.solicitacaoRespondida,
      'doc_id': instance.docId,
      'titulo': instance.titulo,
      'icone': instance.icone,
      'grupo_id': instance.grupoId,
    };
