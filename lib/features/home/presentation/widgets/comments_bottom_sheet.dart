import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/home/domain/entities/comment_entity.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommentChanged;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    this.onCommentChanged,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  CommentEntity? _replyToComment;
  String? _rootCommentIdForReply;
  String? _editingCommentId;
  String? _currentUserId;
  final Set<String> _expandedComments = {};
  List<CommentEntity> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _currentUserId = getIt<FeedRepository>().getCurrentUserId();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final result = await getIt<FeedRepository>().getComments(widget.postId);
    result.fold(
      (error) => null, // Handle error
      (comments) => setState(() {
        _comments = comments;
        _isLoading = false;
      }),
    );
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final text = _commentController.text;
    final parentCommentId = _rootCommentIdForReply;
    final editingId = _editingCommentId;

    _commentController.clear();
    setState(() {
      _replyToComment = null;
      _rootCommentIdForReply = null;
      _editingCommentId = null;
    });

    if (editingId != null) {
      final result = await getIt<FeedRepository>().updateComment(
        editingId,
        text,
      );
      result.fold(
        (error) => null, // Handle error
        (_) => _loadComments(),
      );
      return;
    }

    final result = await getIt<FeedRepository>().addComment(
      widget.postId,
      text,
      parentCommentId: parentCommentId,
    );
    result.fold(
      (error) => null, // Handle error
      (comment) {
        widget.onCommentChanged?.call();
        if (parentCommentId != null) {
          _loadComments(); // Reload to show reply in tree
        } else {
          setState(() => _comments.add(comment));
        }
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final result = await getIt<FeedRepository>().deleteComment(commentId);
    result.fold(
      (error) => null, // Handle error
      (_) {
        widget.onCommentChanged?.call();
        _loadComments();
      },
    );
  }

  Future<void> _toggleLikeComment(CommentEntity comment) async {
    final repo = getIt<FeedRepository>();
    final isLiked = comment.isLiked;

    // Optimistic update
    setState(() {
      _updateCommentInList(comment.id, (c) {
        return c.copyWith(
          isLiked: !isLiked,
          likesCount: isLiked ? c.likesCount - 1 : c.likesCount + 1,
        );
      });
    });

    final result = isLiked
        ? await repo.unlikeComment(comment.id)
        : await repo.likeComment(comment.id);

    result.fold((error) {
      // Rollback on error
      setState(() {
        _updateCommentInList(comment.id, (c) {
          return c.copyWith(
            isLiked: isLiked,
            likesCount: isLiked ? c.likesCount + 1 : c.likesCount - 1,
          );
        });
      });
    }, (_) => null);
  }

  void _updateCommentInList(
    String commentId,
    CommentEntity Function(CommentEntity) updateFn,
  ) {
    _comments = _comments.map((c) {
      if (c.id == commentId) {
        return updateFn(c);
      }
      if (c.replies.isNotEmpty) {
        final updatedReplies = c.replies.map((r) {
          if (r.id == commentId) {
            return updateFn(r);
          }
          return r;
        }).toList();
        return c.copyWith(replies: updatedReplies);
      }
      return c;
    }).toList();
  }

  void _onEditComment(CommentEntity comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.text;
      _replyToComment = null;
      _rootCommentIdForReply = null;
    });
    _focusNode.requestFocus();
  }

  void _showCommentOptions(CommentEntity comment) {
    if (_currentUserId != comment.userId) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar comentário'),
              onTap: () {
                Navigator.pop(context);
                _onEditComment(comment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Excluir comentário',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteComment(comment.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text('Comentários', style: AppTextStyles.h3.copyWith(fontSize: 18)),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(_comments[index]);
                    },
                  ),
          ),

          // Input field
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.05,
                  ),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyToComment != null || _editingCommentId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _editingCommentId != null
                                ? 'Editando comentário'
                                : 'Respondendo a ${_replyToComment!.userName}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _replyToComment = null;
                            _rootCommentIdForReply = null;
                            _editingCommentId = null;
                            _commentController.clear();
                          }),
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final avatarUrl = state.maybeWhen(
                          authenticated: (user) => user.avatarUrl,
                          orElse: () => null,
                        );

                        return CircleAvatar(
                          radius: 18,
                          backgroundImage: avatarUrl != null
                              ? CachedNetworkImageProvider(avatarUrl)
                              : null,
                          backgroundColor: AppColors.primary.withAlpha(50),
                          child: avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: AppColors.primary,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Adicione um comentário',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: _sendComment,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    CommentEntity comment, {
    bool isReply = false,
    String? rootCommentId,
  }) {
    final currentRootId = rootCommentId ?? comment.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/profile/${comment.userId}'),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[100],
                  backgroundImage: comment.userAvatar != null
                      ? CachedNetworkImageProvider(comment.userAvatar!)
                      : null,
                  child: comment.userAvatar == null
                      ? Icon(
                          Icons.person,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onLongPress: () => _showCommentOptions(comment),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '${comment.userName} ',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    context.push('/profile/${comment.userId}'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isReply ? 13 : 12,
                              ),
                            ),
                            WidgetSpan(
                              child: SizedBox(width: isReply ? 12 : 4),
                            ),
                            TextSpan(
                              text: _getTimeAgo(comment.createdAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(comment.text, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _toggleLikeComment(comment),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        comment.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 18,
                        color: comment.isLiked
                            ? Colors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (comment.likesCount > 0)
                    Text(
                      '${comment.likesCount}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _replyToComment = comment;
                      _rootCommentIdForReply = currentRootId;
                      _editingCommentId = null;

                      if (isReply) {
                        _commentController.text = '@${comment.userName} ';
                        _commentController
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _commentController.text.length),
                        );
                      } else {
                        _commentController.clear();
                      }
                    });
                    _focusNode.requestFocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Responder',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Replies Toggle
          if (!isReply && comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 1,
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_expandedComments.contains(comment.id)) {
                          _expandedComments.remove(comment.id);
                        } else {
                          _expandedComments.add(comment.id);
                        }
                      });
                    },
                    child: Text(
                      _expandedComments.contains(comment.id)
                          ? 'Ocultar respostas'
                          : 'Ver mais ${comment.replies.length} ${comment.replies.length == 1 ? 'resposta' : 'respostas'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Replies
          if (comment.replies.isNotEmpty &&
              (isReply || _expandedComments.contains(comment.id)))
            Padding(
              padding: EdgeInsets.only(
                left: isReply ? 0 : 48, // Limit indentation to one level
                top: AppSpacing.sm,
              ),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => _buildCommentItem(
                        reply,
                        isReply: true,
                        rootCommentId: currentRootId,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
