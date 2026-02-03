import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_entity.freezed.dart';

@freezed
abstract class PostEntity with _$PostEntity {
  const factory PostEntity({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    String? missionName,
    String? missionId,
    required List<String> images,
    required String caption,
    @Default(false) bool isPrivate,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    required DateTime createdAt,
  }) = _PostEntity;

  const PostEntity._();
}
