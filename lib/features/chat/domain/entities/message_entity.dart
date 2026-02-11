import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_entity.freezed.dart';

enum MessageType { me, other, guide }

@freezed
abstract class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String id,
    required String text,
    required DateTime timestamp,
    required MessageType type,
    String? userName,
    String? userAvatarUrl,
    String? guideRole,
    String? attachmentUrl,
    MessageEntity? repliedToMessage,
    required bool isEdited,
    required bool isDeleted,
  }) = _MessageEntity;

  const MessageEntity._();
}
