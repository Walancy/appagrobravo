import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_entity.freezed.dart';

@freezed
abstract class CommentEntity with _$CommentEntity {
  const factory CommentEntity({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
    required DateTime createdAt,
    @Default([]) List<CommentEntity> replies,
  }) = _CommentEntity;

  const CommentEntity._();
}
