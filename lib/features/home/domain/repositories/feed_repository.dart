import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/domain/entities/comment_entity.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';

abstract class FeedRepository {
  Future<Either<Exception, List<PostEntity>>> getFeed();
  Future<Either<Exception, List<CommentEntity>>> getComments(String postId);
  Future<Either<Exception, Unit>> likePost(String postId);
  Future<Either<Exception, Unit>> unlikePost(String postId);
  Future<Either<Exception, CommentEntity>> addComment(
    String postId,
    String text, {
    String? parentCommentId,
  });
  Future<Either<Exception, Unit>> updateComment(String commentId, String text);
  Future<Either<Exception, Unit>> deleteComment(String commentId);
  Future<Either<Exception, PostEntity>> createPost({
    required List<String> imagePaths,
    required String caption,
    String? missionId,
    bool privado = false,
  });
  Future<Either<Exception, PostEntity>> updatePost({
    required String postId,
    required List<String> images, // Mixture of new paths and existing URLs
    required String caption,
    String? missionId,
    required bool privado,
  });
  Future<Either<Exception, bool>> canUserPost();
  Future<Either<Exception, List<MissionEntity>>> getUserMissions();
  Future<Either<Exception, Unit>> deletePost(String postId);
  String? getCurrentUserId();
}
