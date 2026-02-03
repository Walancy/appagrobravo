import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/tokens/assets.gen.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/home/presentation/cubit/feed_cubit.dart';
import 'package:agrobravo/features/home/presentation/cubit/feed_state.dart';
import 'package:agrobravo/features/home/presentation/widgets/post_card.dart';
import 'package:agrobravo/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:agrobravo/features/home/presentation/widgets/new_post_bottom_sheet.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/features/itinerary/presentation/pages/itinerary_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedCubit>()..loadFeed(),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: _buildHeader(context),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppHeader(
      mode: HeaderMode.home,
      logo: SvgPicture.asset(Assets.images.logoColorida, height: 32),
      actions: [
        BlocBuilder<FeedCubit, FeedState>(
          builder: (context, state) {
            final canPost = state.maybeWhen(
              loaded: (_, canPost) => canPost,
              orElse: () => false,
            );

            return IconButton(
              onPressed: canPost ? () => _handleNewPost(context) : null,
              icon: Icon(
                Icons.add_circle_outline_rounded,
                size: 28,
                color: canPost ? AppColors.textPrimary : Colors.grey,
              ),
            );
          },
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return const ChatPage();
    }

    if (_selectedIndex == 2) {
      return const ItineraryTab();
    }

    if (_selectedIndex != 0) {
      return Container(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Text(
            'Conteúdo da Página ${_selectedIndex == 3 ? "Perfil" : ""}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (message) => Center(child: Text(message)),
          loaded: (posts, _) {
            if (posts.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma publicação encontrada.',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }
            return RefreshIndicator(
              edgeOffset: 120,
              onRefresh: () => context.read<FeedCubit>().loadFeed(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 130, bottom: AppSpacing.md),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final currentUserId = getIt<FeedRepository>()
                      .getCurrentUserId();
                  final isOwner = post.userId == currentUserId;

                  return PostCard(
                    post: post,
                    isOwner: isOwner,
                    onLike: () => context.read<FeedCubit>().toggleLike(post.id),
                    onComment: () => _showComments(context, post.id),
                    onDelete: () => _confirmDeletePost(context, post.id),
                    onEdit: () async {
                      final result = await context.push<bool>(
                        '/create-post',
                        extra: {
                          'initialImages': post
                              .images, // Not really used for edit as we pass the whole post, but signature requires list
                          'postToEdit': post,
                        },
                      );
                      if (result == true && context.mounted) {
                        context.read<FeedCubit>().loadFeed();
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showComments(BuildContext context, String postId) {
    final feedCubit = context.read<FeedCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        onCommentChanged: () => feedCubit.loadFeed(),
      ),
    );
  }

  Future<void> _handleNewPost(BuildContext context) async {
    final picker = ImagePicker();
    final isCamera = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostBottomSheet(
        onSourceSelected: (camera) => Navigator.pop(context, camera),
      ),
    );

    if (isCamera != null) {
      final source = isCamera ? ImageSource.camera : ImageSource.gallery;
      try {
        final image = await picker.pickImage(source: source);
        if (!mounted) return;

        if (image != null) {
          if (context.mounted) {
            final result = await context.push<bool>(
              '/create-post',
              extra: [image.path],
            );
            if (result == true && context.mounted) {
              context.read<FeedCubit>().loadFeed();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este dispositivo não suporta o uso da câmera.'),
            ),
          );
        }
      }
    }
  }

  void _confirmDeletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Publicação'),
        content: const Text('Tem certeza que deseja excluir esta publicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.read<FeedCubit>().deletePost(postId); // Helper to delete
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
            _buildNavItem(
              1,
              Icons.chat_bubble_outline_rounded,
              Icons.chat_bubble_rounded,
              'Chat',
            ),
            _buildNavItem(
              2,
              Icons.explore_outlined,
              Icons.explore_rounded,
              'Itinerário',
            ),
            _buildNavItem(
              3,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Perfil',
              hasBadge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    bool hasBadge = false,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textPrimary;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, color: color, size: 28),
                if (hasBadge)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ).animate(isSelected),
    );
  }
}

extension on Widget {
  Widget animate(bool isSelected) {
    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: this,
    );
  }
}
