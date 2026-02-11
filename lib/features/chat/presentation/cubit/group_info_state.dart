import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';

part 'group_info_state.freezed.dart';

@freezed
class GroupInfoState with _$GroupInfoState {
  const factory GroupInfoState.initial() = _Initial;
  const factory GroupInfoState.loading() = _Loading;
  const factory GroupInfoState.loaded(GroupDetailEntity details) = _Loaded;
  const factory GroupInfoState.error(String message) = _Error;
}
