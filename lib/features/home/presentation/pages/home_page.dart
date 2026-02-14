import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

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
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/profile/presentation/pages/profile_tab.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:agrobravo/features/home/presentation/widgets/itinerary_microcards.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';
import 'package:agrobravo/features/home/presentation/widgets/mission_alert_dialog.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/emergency_modal.dart';
import 'package:agrobravo/core/components/feed_shimmer.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final documentsCubit = context.read<DocumentsCubit>();
      documentsCubit.state.maybeMap(
        initial: (_) => documentsCubit.loadDocuments(),
        orElse: () {},
      );

      final notificationsCubit = context.read<NotificationsCubit>();
      notificationsCubit.state.maybeMap(
        initial: (_) => notificationsCubit.loadNotifications(),
        orElse: () {},
      );

      final itineraryCubit = context.read<ItineraryCubit>();
      itineraryCubit.state.maybeMap(
        initial: (_) => itineraryCubit.loadUserItinerary(),
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showMissionAlert(BuildContext context, MissionEntity mission) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MissionAlertDialog(
        mission: mission,
        onDismiss: (permanently) {
          context.read<FeedCubit>().acknowledgeMissionAlert(
            mission.id,
            permanently: permanently,
          );
        },
        onDocumentsTap: () {
          Navigator.pop(dialogContext);
          context.push('/documents');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedCubit>()..loadFeed(),
      child: BlocListener<FeedCubit, FeedState>(
        listener: (context, state) {
          state.maybeMap(
            loaded: (s) {
              if (s.missionToAlert != null) {
                _showMissionAlert(context, s.missionToAlert!);
              }
            },
            orElse: () {},
          );
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildHeader(context),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNav(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppHeader(
      mode: HeaderMode.home,
      logo: SvgPicture.asset(Assets.images.logoColorida, height: 32),
      actions: [
        if (_selectedIndex == 0)
          BlocBuilder<FeedCubit, FeedState>(
            builder: (context, state) {
              final canPost = state.maybeWhen(
                loaded: (_, canPost, __) => canPost,
                orElse: () => false,
              );

              return IconButton(
                onPressed: canPost ? () => _handleNewPost(context) : null,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 28,
                  color: canPost
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                ),
              );
            },
          ),
        if (_selectedIndex == 3)
          BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, state) {
              final hasPending = state.hasPendingAction;
              return IconButton(
                onPressed: () => context.push('/settings'),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.settings_outlined, size: 28),
                    if (hasPending)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final hasUnread = state.hasUnread;
            return IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (_selectedIndex == 2)
          IconButton(
            onPressed: () => _showEmergencyModal(context),
            icon: const Icon(
              Icons.emergency_outlined,
              size: 28,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  void _showEmergencyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmergencyModal(),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return const ChatPage();
    }

    if (_selectedIndex == 2) {
      return const ItineraryTab();
    }

    if (_selectedIndex == 3) {
      return const ProfileTab();
    }

    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const FeedShimmer(),
          error: (message) => Center(child: Text(message)),
          loaded: (posts, _, __) {
            if (posts.isEmpty) {
              return RefreshIndicator(
                edgeOffset: 120,
                onRefresh: () => context.read<FeedCubit>().loadFeed(),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const HeaderSpacer(),
                    ItineraryMicrocards(
                      onSeeAll: () => setState(() => _selectedIndex = 2),
                    ),
                    Center(
                      child: Text(
                        'Nenhuma publicação encontrada.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              edgeOffset: 120,
              onRefresh: () => context.read<FeedCubit>().loadFeed(),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: posts.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) return const HeaderSpacer();
                  if (index == 1) {
                    return ItineraryMicrocards(
                      onSeeAll: () => setState(() => _selectedIndex = 2),
                    );
                  }

                  final post = posts[index - 2];
                  final currentUserId = getIt<FeedRepository>()
                      .getCurrentUserId();
                  final isOwner = post.userId == currentUserId;

                  return PostCard(
                    post: post,
                    isOwner: isOwner,
                    onLike: () => context.read<FeedCubit>().toggleLike(post.id),
                    onComment: () => _showComments(context, post.id),
                    onDelete: () => _confirmDeletePost(context, post.id),
                    onProfileTap: () => context.push('/profile/${post.userId}'),
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
              extra: [image],
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
    final feedCubit = context.read<FeedCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Publicação'),
        content: const Text('Tem certeza que deseja excluir esta publicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              feedCubit.deletePost(postId);
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
      padding: EdgeInsets.fromLTRB(
        0,
        10,
        0,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_outlined, 'Inicio'),
          _buildNavItem(
            1,
            Icons.chat_bubble_outline_rounded,
            Icons.chat_bubble_outline_rounded,
            'Chat',
          ),
          _buildNavItem(
            2,
            Icons.explore_outlined,
            Icons.explore_outlined,
            'Itinerário',
          ),
          BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, state) {
              return _buildNavItem(
                3,
                Icons.person_outline_rounded,
                Icons.person_outline_rounded,
                'Perfil',
                hasBadge: state.hasPendingAction,
              );
            },
          ),
        ],
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
    final color = isSelected
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isSelected ? activeIcon : icon, color: color, size: 24),
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
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
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
                fontSize: 10,
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
