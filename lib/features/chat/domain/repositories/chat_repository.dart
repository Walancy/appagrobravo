import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Exception, ChatData>> getChatData();
  Stream<List<MessageEntity>> getMessages(String chatId, {bool isGroup = true});
  Future<void> sendMessage(
    String chatId,
    String text, {
    bool isGroup = true,
    XFile? image,
    String? replyToId,
  });
  Future<void> editMessage(String messageId, String newText);
  Future<void> deleteMessages(List<String> messageIds);
  Future<Either<Exception, GroupDetailEntity>> getGroupDetails(String groupId);
}
