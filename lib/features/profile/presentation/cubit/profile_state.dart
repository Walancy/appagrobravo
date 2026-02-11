import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({
    required ProfileEntity profile,
    required List<PostEntity> posts,
    required bool isMe,
    @Default(false) bool isEditing,
  }) = _Loaded;
  const factory ProfileState.error(String message) = _Error;
}
