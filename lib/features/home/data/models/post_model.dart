import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
abstract class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'missao_id') String? missaoId,
    required List<String> imagens,
    required String legenda,
    @JsonKey(name: 'n_curtidas') @Default(0) int likesCount,
    @JsonKey(name: 'n_comentarios') @Default(0) int commentsCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'privado') @Default(false) bool privado,
    // Joined data
    String? userName,
    String? userAvatar,
    String? missionName,
    @Default(false) bool isLiked,
  }) = _PostModel;

  const PostModel._();

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  PostEntity toEntity() => PostEntity(
    id: id,
    userId: userId,
    userName: userName ?? 'Usuário',
    userAvatar: userAvatar,
    missionName: missionName,
    missionId: missaoId,
    images: imagens,
    caption: legenda,
    isPrivate: privado,
    likesCount: likesCount,
    commentsCount: commentsCount,
    isLiked: isLiked,
    createdAt: createdAt,
  );
}
