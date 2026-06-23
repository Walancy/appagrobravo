import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String? mensagem,
    required bool? lido,
    @JsonKey(name: 'user_id') required String? userId,
    String? assunto,
    @JsonKey(name: 'missao_id') String? missionId,
    @JsonKey(name: 'post_id') String? postId,
    @JsonKey(name: 'solicitacao_user_id') String? solicitacaoUserId,
    @JsonKey(name: 'solicitacaorespondida') bool? solicitacaoRespondida,
    @JsonKey(name: 'doc_id') String? docId,
    String? titulo,
    String? icone,
    String? tipo,
    @JsonKey(name: 'grupo_id') String? grupoId,
    @JsonKey(name: 'batepapo_id') String? batepapoId,
    @JsonKey(name: 'target_route') String? targetRoute,
    // Joined data from users table (if any)
    @JsonKey(ignore: true) String? userName,
    @JsonKey(ignore: true) String? userAvatar,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  NotificationEntity toEntity() {
    NotificationType type;

    final subject = assunto?.toLowerCase() ?? '';
    final title = titulo?.toLowerCase() ?? '';
    final messageContent = mensagem ?? '';
    final messageLower = messageContent.toLowerCase();

    // Use `tipo` field from panel as primary classification, fall back to text parsing.
    final tipoValue = tipo?.toLowerCase() ?? '';
    if (tipoValue.isNotEmpty) {
      switch (tipoValue) {
        case 'missionupdate':
        case 'mission_update':
          type = NotificationType.missionUpdate;
        case 'guidealert':
        case 'guide_alert':
          type = NotificationType.guideAlert;
        case 'documentapproved':
        case 'document_approved':
          type = NotificationType.documentApproved;
        case 'documentrejected':
        case 'document_rejected':
          type = NotificationType.documentRejected;
        case 'documentpending':
        case 'document_pending':
          type = NotificationType.documentPending;
        case 'like':
          type = NotificationType.like;
        case 'comment':
          type = NotificationType.comment;
        case 'mention':
          type = NotificationType.mention;
        case 'follow':
          type = NotificationType.follow;
        default:
          type = NotificationType.missionUpdate;
      }
    } else if (docId != null) {
      if (title.contains('aprovado')) {
        type = NotificationType.documentApproved;
      } else if (title.contains('recusado') || title.contains('rejeitado')) {
        type = NotificationType.documentRejected;
      } else {
        type = NotificationType.documentPending;
      }
    } else if (postId != null) {
      if (subject.contains('curtiu')) {
        type = NotificationType.like;
      } else if (subject.contains('comentou')) {
        type = NotificationType.comment;
      } else if (subject.contains('mencionou')) {
        type = NotificationType.mention;
      } else {
        type = NotificationType.like;
      }
    } else if (subject == 'chatgrupo' || subject == 'chatdireto') {
      type = NotificationType.chatMessage;
    } else if (solicitacaoUserId != null) {
      final isFollowKeyword =
          subject.contains('solicitação') ||
          subject.contains('conexo') ||
          subject.contains('seguir') ||
          title.contains('solicitação') ||
          title.contains('conexo') ||
          title.contains('seguir') ||
          messageLower.contains('seguir') ||
          messageLower.contains('conexão');

      if (isFollowKeyword) {
        type = NotificationType.follow;
      } else {
        type = NotificationType.missionUpdate;
      }
    } else if (missionId != null || grupoId != null) {
      if (subject.contains('guia') || title.contains('guia')) {
        type = NotificationType.guideAlert;
      } else {
        type = NotificationType.missionUpdate;
      }
    } else {
      type = NotificationType.missionUpdate;
    }

    String finalUserName = userName ?? titulo ?? 'AgroBravo';
    String finalMessage = messageContent;

    // Name parsing for Post interactions if name is 'AgroBravo'
    if (finalUserName == 'AgroBravo' &&
        (type == NotificationType.like ||
            type == NotificationType.comment ||
            type == NotificationType.mention)) {
      final keywords = ['curtiu', 'comentou', 'mencionou'];
      for (final kw in keywords) {
        if (finalMessage.contains(' $kw ')) {
          final parts = finalMessage.split(' $kw ');
          if (parts[0].trim().isNotEmpty) {
            finalUserName = parts[0].trim();
            finalMessage = '$kw ${parts[1]}';
            break;
          }
        }
      }
    }

    // Generate fallback target_route when not set in DB (backward compatibility)
    String? resolvedRoute = targetRoute;
    if (resolvedRoute == null || resolvedRoute.isEmpty) {
      switch (type) {
        case NotificationType.like:
        case NotificationType.comment:
        case NotificationType.mention:
          // Will be resolved in repository with postOwnerId
          break;
        case NotificationType.follow:
          // Will be resolved in repository with current user ID
          break;
        case NotificationType.missionUpdate:
        case NotificationType.guideAlert:
          if (grupoId != null) resolvedRoute = '/home?tab=0&groupId=$grupoId';
          break;
        case NotificationType.documentApproved:
        case NotificationType.documentRejected:
        case NotificationType.documentPending:
          resolvedRoute = '/documents';
          break;
        case NotificationType.chatMessage:
          if (grupoId != null) {
            resolvedRoute = '/chat-group/$grupoId';
          } else if (batepapoId != null) {
            resolvedRoute = '/chat-direct/$batepapoId';
          }
          break;
      }
    }

    return NotificationEntity(
      id: id,
      userName: finalUserName,
      userAvatar: userAvatar,
      type: type,
      postImage: null,
      postId: postId,
      solicitacaoUserId: solicitacaoUserId,
      docId: docId,
      postOwnerId: null, // Will be set in repository
      batepapoId: batepapoId,
      grupoId: grupoId,
      message: finalMessage,
      createdAt: createdAt,
      isRead: (lido ?? false) || (solicitacaoRespondida ?? false),
      targetRoute: resolvedRoute,
    );
  }
}
