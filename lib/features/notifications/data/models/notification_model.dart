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
    @JsonKey(name: 'grupo_id') String? grupoId,
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

    // Specific detection logic
    if (docId != null) {
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
    } else if (solicitacaoUserId != null) {
      // Check if it's really a follow request
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
        // Just a generic notification from a user (e.g. mention without postId or message)
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

    String finalUserName = userName ?? 'AgroBravo';
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
      message: finalMessage,
      createdAt: createdAt,
      isRead: (lido ?? false) || (solicitacaoRespondida ?? false),
    );
  }
}
