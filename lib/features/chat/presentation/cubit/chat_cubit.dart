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

  ChatCubit(this._repository) : super(const ChatState.initial());

  Future<void> loadChatData() async {
    emit(const ChatState.loading());
    final result = await _repository.getChatData();
    result.fold(
      (error) => emit(ChatState.error(error.toString())),
      (data) => emit(ChatState.loaded(data)),
    );
  }
}
