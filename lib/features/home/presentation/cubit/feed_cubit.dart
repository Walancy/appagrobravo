import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/features/home/presentation/cubit/feed_state.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';

@injectable
class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _feedRepository;

  FeedCubit(this._feedRepository) : super(const FeedState.initial());

  Future<void> loadFeed() async {
    emit(const FeedState.loading());

    final canPostResult = await _feedRepository.canUserPost();
    final feedResult = await _feedRepository.getFeed();

    final canPost = canPostResult.getOrElse(() => false);

    feedResult.fold(
      (error) => emit(FeedState.error(error.toString())),
      (posts) => emit(FeedState.loaded(posts, canPost)),
    );
  }

  Future<void> toggleLike(String postId) async {
    state.maybeWhen(
      loaded: (posts, canPost) async {
        final updatedPosts = List<PostEntity>.from(posts);
        final index = updatedPosts.indexWhere((p) => p.id == postId);
        if (index == -1) return;

        final post = updatedPosts[index];
        final isLiked = post.isLiked;

        // Optimistic update
        updatedPosts[index] = post.copyWith(
          isLiked: !isLiked,
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        emit(FeedState.loaded(updatedPosts, canPost));

        final result = isLiked
            ? await _feedRepository.unlikePost(postId)
            : await _feedRepository.likePost(postId);

        result.fold((error) {
          // Rollback on error
          updatedPosts[index] = post;
          emit(FeedState.loaded(updatedPosts, canPost));
        }, (_) => null);
      },
      orElse: () => null,
    );
  }

  Future<void> deletePost(String postId) async {
    state.maybeWhen(
      loaded: (posts, canPost) async {
        // Optimistic update
        final updatedPosts = List<PostEntity>.from(posts)
          ..removeWhere((p) => p.id == postId);

        emit(FeedState.loaded(updatedPosts, canPost));

        final result = await _feedRepository.deletePost(postId);

        result.fold((error) {
          // Rollback
          // In this case, we'd theoretically re-fetch or put it back,
          // but for simplicity we reload the feed on error to restore state
          loadFeed();
        }, (_) => null);
      },
      orElse: () => null,
    );
  }

  Future<void> updatePost(
    String postId,
    List<String> images,
    String caption,
    String? missionId,
    bool privado,
  ) async {
    final result = await _feedRepository.updatePost(
      postId: postId,
      images: images,
      caption: caption,
      missionId: missionId,
      privado: privado,
    );

    result.fold((error) => null, (updatedPost) {
      state.maybeWhen(
        loaded: (posts, canPost) {
          final updatedPosts = List<PostEntity>.from(posts);
          final index = updatedPosts.indexWhere((p) => p.id == postId);
          if (index != -1) {
            updatedPosts[index] = updatedPost;
            emit(FeedState.loaded(updatedPosts, canPost));
          } else {
            loadFeed();
          }
        },
        orElse: () => null,
      );
    });
  }
}
