import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';

part 'chat_detail_state.freezed.dart';

@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState.initial() = _Initial;
  const factory ChatDetailState.loading() = _Loading;
  const factory ChatDetailState.loaded(List<MessageEntity> messages) = _Loaded;
  const factory ChatDetailState.error(String message) = _Error;
}
