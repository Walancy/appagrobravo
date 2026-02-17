import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/home/presentation/widgets/post_card.dart';
import 'package:agrobravo/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/presentation/cubit/feed_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserFeedPage extends StatefulWidget {
  final String userId;
  final String? initialPostId;

  const UserFeedPage({super.key, required this.userId, this.initialPostId});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  List<PostEntity> _posts = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final result = await getIt<ProfileRepository>().getUserPosts(widget.userId);
    if (mounted) {
      result.fold(
        (error) => setState(() {
          _error = error.toString();
          _isLoading = false;
        }),
        (posts) {
          setState(() {
            _posts = posts;
            _isLoading = false;
          });

          // Scroll to initial post if provided
          if (widget.initialPostId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final index = _posts.indexWhere(
                (p) => p.id == widget.initialPostId,
              );
              if (index != -1) {
                // Approximate position based on average PostCard height
                _scrollController.jumpTo(index * 550.0 + 130.0);
              }
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedCubit>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppHeader(mode: HeaderMode.back, title: 'Publicações'),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _posts.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma publicação encontrada.',
                  style: AppTextStyles.bodyMedium,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 130, bottom: AppSpacing.md),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return PostCard(
                    post: post,
                    isOwner: true,
                    onLike: () => context.read<FeedCubit>().toggleLike(post.id),
                    onComment: () => _showComments(context, post.id),
                    onProfileTap: () => context.push('/profile/${post.userId}'),
                  );
                },
              ),
      ),
    );
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        onCommentChanged: () => _loadPosts(),
      ),
    );
  }
}
