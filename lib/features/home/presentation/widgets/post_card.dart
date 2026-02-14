import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PostCard extends StatefulWidget {
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;
  bool _isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );

    _likeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _likeController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _isLikeAnimating = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleDoubleTapLike() {
    widget.onLike();
    setState(() {
      _isLikeAnimating = true;
    });
    _likeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.post.userAvatar == null
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey[100])
                        : Colors.transparent,
                    backgroundImage: widget.post.userAvatar != null
                        ? CachedNetworkImageProvider(widget.post.userAvatar!)
                        : null,
                    child: widget.post.userAvatar == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 20,
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
                    onTap: widget.onProfileTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.post.missionName != null)
                          Text(
                            widget.post.missionName!,
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
                if (widget.isOwner)
                  PopupMenuButton<String>(
                    color: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Theme.of(context).colorScheme.surface,
                    onSelected: (value) {
                      if (value == 'delete') {
                        widget.onDelete?.call();
                      } else if (value == 'edit') {
                        widget.onEdit?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Images PageView with dynamic aspect ratio and Like Animation
          if (widget.post.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: GestureDetector(
                onDoubleTap: _handleDoubleTapLike,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _PostImageSlider(images: widget.post.images),
                    if (_isLikeAnimating)
                      ScaleTransition(
                        scale: _likeAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00FF88), Color(0xFF00CCFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
                  context,
                  icon: widget.post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: widget.post.isLiked
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
                  count: widget.post.likesCount,
                  onTap: widget.onLike,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildAction(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  count: widget.post.commentsCount,
                  onTap: widget.onComment,
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
                  onTap: widget.onProfileTap,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: '${widget.post.userName} ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: widget.post.caption,
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
                  _formatDate(widget.post.createdAt).toUpperCase(),
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

  Widget _buildAction(
    BuildContext context, {
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
              color: color ?? Theme.of(context).colorScheme.onSurface,
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
    final ImageStream stream = CachedNetworkImageProvider(
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : Colors.grey[200],
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
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                    highlightColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF121212)
                        : Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 40,
                      ),
                    ),
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
