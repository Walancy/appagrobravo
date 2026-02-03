import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/home/domain/entities/comment_entity.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'comentario') required String text,
    @JsonKey(name: 'id_comentario') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined data
    @JsonKey(includeToJson: false) String? userName,
    @JsonKey(includeToJson: false) String? userAvatar,
  }) = _CommentModel;

  const CommentModel._();

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  CommentEntity toEntity({List<CommentEntity> replies = const []}) =>
      CommentEntity(
        id: id,
        userId: userId,
        userName: userName ?? 'Usuário',
        userAvatar: userAvatar,
        text: text,
        createdAt: createdAt,
        replies: replies,
      );
}
