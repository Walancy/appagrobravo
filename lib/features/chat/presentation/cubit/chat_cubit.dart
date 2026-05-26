import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _chatDataSubscription;

  ChatCubit(this._repository) : super(const ChatState.initial());

  @override
  Future<void> close() {
    _chatDataSubscription?.cancel();
    return super.close();
  }

  Future<void> loadChatData() async {
    emit(const ChatState.loading());
    final result = await _repository.getChatData();
    result.fold(
      (error) => emit(ChatState.error(error.toString())),
      (data) => emit(ChatState.loaded(data)),
    );
  }

  void watchChatData() {
    emit(const ChatState.loading());
    _chatDataSubscription?.cancel();
    _chatDataSubscription = _repository.watchChatData().listen(
      (result) {
        if (isClosed) return;
        result.fold(
          (error) => emit(ChatState.error(error.toString())),
          (data) => emit(ChatState.loaded(data)),
        );
      },
      onError: (error) {
        if (!isClosed) emit(ChatState.error(error.toString()));
      },
    );
  }
}
