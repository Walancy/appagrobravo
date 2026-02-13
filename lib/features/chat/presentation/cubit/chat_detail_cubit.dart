import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_state.dart';

@injectable
class ChatDetailCubit extends Cubit<ChatDetailState> {
  final ChatRepository _repository;
  StreamSubscription? _messagesSubscription;
  String? _currentChatId;
  bool _isGroup = true;

  ChatDetailCubit(this._repository) : super(const ChatDetailState.initial());

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  void loadMessages(String chatId, {bool isGroup = true}) {
    _currentChatId = chatId;
    _isGroup = isGroup;
    emit(const ChatDetailState.loading());

    _messagesSubscription?.cancel();
    _messagesSubscription = _repository
        .getMessages(chatId, isGroup: isGroup)
        .listen(
          (messages) {
            emit(ChatDetailState.loaded(messages));
          },
          onError: (error) {
            emit(ChatDetailState.error(error.toString()));
            print('Error in loadMessages: $error');
            print(StackTrace.current);
          },
        );
  }

  Future<void> sendMessage(
    String text, {
    XFile? image,
    String? replyToId,
  }) async {
    if (_currentChatId == null) return;

    try {
      await _repository.sendMessage(
        _currentChatId!,
        text,
        isGroup: _isGroup,
        image: image,
        replyToId: replyToId,
      );
      // No need to emit manually, stream will update
    } catch (e) {
      // Handle error (maybe show snackbar via listener or error state)
      // For now, logging
      print('Error sending message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    try {
      await _repository.editMessage(messageId, newText);
    } catch (e) {
      print('Error editing message: $e');
    }
  }

  Future<void> deleteMessages(List<String> messageIds) async {
    try {
      await _repository.deleteMessages(messageIds);
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }
}
