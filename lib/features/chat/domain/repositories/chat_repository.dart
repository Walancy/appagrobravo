import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Exception, ChatData>> getChatData({String? groupId});
  Stream<Either<Exception, ChatData>> watchChatData({String? groupId});
  Stream<List<MessageEntity>> getMessages(String chatId, {bool isGroup = true});
  Future<void> sendMessage(
    String chatId,
    String text, {
    bool isGroup = true,
    XFile? image,
    String? replyToId,
  });
  Future<void> sendAudio(
    String chatId,
    String audioPath, {
    bool isGroup = true,
    int audioDurationMs = 0,
    String? replyToId,
  });
  Future<void> editMessage(String messageId, String newText);
  Future<void> deleteMessages(List<String> messageIds);
  Future<Either<Exception, GroupDetailEntity>> getGroupDetails(String groupId);
  Future<void> markChatAsRead(String chatId);
}
