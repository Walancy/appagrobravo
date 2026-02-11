import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onProfileTap;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onDelete,
    this.onEdit,
    this.onProfileTap,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: post.userAvatar == null
                        ? Colors.grey[100]
                        : Colors.transparent,
                    backgroundImage: post.userAvatar != null
                        ? NetworkImage(post.userAvatar!)
                        : null,
                    child: post.userAvatar == null
                        ? const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: onProfileTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.missionName != null)
                          Text(
                            post.missionName!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call();
                      } else if (value == 'edit') {
                        onEdit?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Editar',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Excluir',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Images PageView with dynamic aspect ratio
          if (post.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _PostImageSlider(images: post.images),
            ),

          // Actions (Like, Comment) - Instagram Style below image, aligned left
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                _buildAction(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: post.isLiked ? Colors.red : AppColors.textPrimary,
                  count: post.likesCount,
                  onTap: onLike,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: post.commentsCount,
                  onTap: onComment,
                ),
              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '${post.userName} ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: post.caption,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(post.createdAt).toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat("dd 'de' MMMM", 'pt_BR').format(date);
  }
}

class _PostImageSlider extends StatefulWidget {
  final List<String> images;

  const _PostImageSlider({required this.images});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  double _aspectRatio = 1.0;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadImageSize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadImageSize() {
    if (widget.images.isEmpty) return;

    final firstImage = widget.images.first;
    final ImageStream stream = NetworkImage(
      firstImage,
    ).resolve(ImageConfiguration.empty);

    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!mounted) return;

          final width = info.image.width.toDouble();
          final height = info.image.height.toDouble();
          double ratio = width / height;

          // Logic:
          // Taller (Portrait): min 0.8 (4:5) -> 1080x1350
          // Wider (Landscape): max 1.77 (16:9) -> 1080x608

          if (ratio < 0.8) ratio = 0.8;
          if (ratio > 1.77) ratio = 1.77;

          setState(() {
            _aspectRatio = ratio;
            _isLoading = false;
          });
        },
        onError: (exception, stackTrace) {
          if (mounted) setState(() => _isLoading = false);
        },
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(widget.images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),

          if (widget.images.length > 1) ...[
            // Counter
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Left Arrow
            if (_currentPage > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _prevPage,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Right Arrow
            if (_currentPage < widget.images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
