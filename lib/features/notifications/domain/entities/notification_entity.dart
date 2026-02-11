import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  missionUpdate,
  documentApproved,
  documentRejected,
  documentPending,
  guideAlert,
}

@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String userName,
    String? userAvatar,
    required NotificationType type,
    String? postImage,
    String? postId,
    String? solicitacaoUserId,
    String? docId,
    String? postOwnerId,
    required String message,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _NotificationEntity;
}
