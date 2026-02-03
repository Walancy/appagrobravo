import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Exception, ChatData>> getChatData();
}
