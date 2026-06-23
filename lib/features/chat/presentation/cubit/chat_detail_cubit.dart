import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_state.dart';

@injectable
class ChatDetailCubit extends Cubit<ChatDetailState> {
  final ChatRepository _repository;
  StreamSubscription? _messagesSubscription;
  String? _currentChatId;
  bool _isGroup = true;

  /// Mensagens otimistas aguardando confirmação do servidor.
  final List<MessageEntity> _pendingMessages = [];

  ChatDetailCubit(this._repository) : super(const ChatDetailState.initial());

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  void loadMessages(String chatId, {bool isGroup = true}) {
    _currentChatId = chatId;
    _isGroup = isGroup;
    _pendingMessages.clear();
    emit(const ChatDetailState.loading());

    unawaited(_repository.markChatAsRead(chatId));

    _messagesSubscription?.cancel();
    _messagesSubscription = _repository
        .getMessages(chatId, isGroup: isGroup)
        .listen(
          (confirmedMessages) {
            unawaited(_repository.markChatAsRead(chatId));
            _reconcilePending(confirmedMessages);
            emit(ChatDetailState.loaded(
              [...confirmedMessages, ..._pendingMessages],
            ));
          },
          onError: (error) {
            emit(ChatDetailState.error(error.toString().replaceFirst('Exception: ', '')));
            if (kDebugMode) debugPrint('[ChatDetail] loadMessages error: $error');
          },
        );
  }

  MessageEntity _buildPending({
    required String text,
    String? audioUrl,
    String? attachmentUrl,
  }) {
    return MessageEntity(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.me,
      isEdited: false,
      isDeleted: false,
      isPending: true,
      audioUrl: audioUrl,
      attachmentUrl: attachmentUrl,
    );
  }

  void _insertPending(MessageEntity msg) {
    _pendingMessages.add(msg);
    final confirmed = state.whenOrNull(
          loaded: (msgs) => msgs.where((m) => !m.isPending).toList(),
        ) ??
        [];
    emit(ChatDetailState.loaded([...confirmed, ..._pendingMessages]));
  }

  void _removePending(String id) {
    _pendingMessages.removeWhere((m) => m.id == id);
    final confirmed = state.whenOrNull(
          loaded: (msgs) => msgs.where((m) => !m.isPending).toList(),
        ) ??
        [];
    emit(ChatDetailState.loaded([...confirmed, ..._pendingMessages]));
  }

  /// Remove pendentes já confirmados pelo servidor.
  /// Texto: match exato. Áudio/imagem: por tipo + remetente + janela de 60s
  /// (suficiente para tolerar skew de relógio entre device e servidor).
  void _reconcilePending(List<MessageEntity> confirmed) {
    _pendingMessages.removeWhere((pending) {
      if (pending.audioUrl != null) {
        return confirmed.any(
          (m) =>
              m.audioUrl != null &&
              m.audioUrl != 'pending' &&
              !m.isPending &&
              m.type == MessageType.me &&
              !m.timestamp.isBefore(
                pending.timestamp.subtract(const Duration(minutes: 1)),
              ),
        );
      } else if (pending.attachmentUrl != null) {
        return confirmed.any(
          (m) =>
              m.attachmentUrl != null &&
              m.attachmentUrl != 'pending' &&
              !m.isPending &&
              m.type == MessageType.me &&
              !m.timestamp.isBefore(
                pending.timestamp.subtract(const Duration(minutes: 1)),
              ),
        );
      } else {
        return confirmed.any(
          (m) => m.text == pending.text && !m.isPending && m.type == MessageType.me,
        );
      }
    });
  }

  Future<void> sendMessage(
    String text, {
    XFile? image,
    String? replyToId,
  }) async {
    if (_currentChatId == null) return;

    final pending = _buildPending(
      text: text,
      attachmentUrl: image != null ? 'pending' : null,
    );
    _insertPending(pending);

    try {
      await _repository.sendMessage(
        _currentChatId!,
        text,
        isGroup: _isGroup,
        image: image,
        replyToId: replyToId,
      );
    } catch (e) {
      _removePending(pending.id);
      if (kDebugMode) debugPrint('[ChatDetail] sendMessage error: $e');
    }
  }

  Future<void> sendAudioMessage(
    String audioPath, {
    int audioDurationMs = 0,
    String? replyToId,
  }) async {
    if (_currentChatId == null) return;

    final pending = _buildPending(text: '', audioUrl: 'pending');
    _insertPending(pending);

    try {
      await _repository.sendAudio(
        _currentChatId!,
        audioPath,
        isGroup: _isGroup,
        audioDurationMs: audioDurationMs,
        replyToId: replyToId,
      );
    } catch (e) {
      _removePending(pending.id);
      if (kDebugMode) debugPrint('[ChatDetail] sendAudio error: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    try {
      await _repository.editMessage(messageId, newText);
    } catch (e) {
      if (kDebugMode) debugPrint('[ChatDetail] editMessage error: $e');
    }
  }

  Future<void> deleteMessages(List<String> messageIds) async {
    try {
      await _repository.deleteMessages(messageIds);
    } catch (e) {
      if (kDebugMode) debugPrint('[ChatDetail] deleteMessages error: $e');
    }
  }
}
