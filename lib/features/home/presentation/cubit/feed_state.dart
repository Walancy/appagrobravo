import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';

part 'feed_state.freezed.dart';

@freezed
abstract class FeedState with _$FeedState {
  const factory FeedState.initial() = _Initial;
  const factory FeedState.loading() = _Loading;
  const factory FeedState.loaded(
    List<PostEntity> posts,
    bool canPost, {
    MissionEntity? missionToAlert,
  }) = _Loaded;
  const factory FeedState.error(String message) = _Error;
}
