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
import 'package:agrobravo/core/components/empty_state_widget.dart';
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
import 'package:agrobravo/features/itinerary/presentation/widgets/emergency_modal.dart';
import 'package:agrobravo/core/components/feed_shimmer.dart';
import 'package:agrobravo/features/home/presentation/pages/community_tab.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/profile/presentation/widgets/incomplete_profile_banner.dart';
import 'package:agrobravo/features/documents/presentation/widgets/pending_documents_banner.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstAccessPrompt();

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
      itineraryCubit.listenToGroupChanges();
      // Always reload on home entry — the singleton cubit may retain a stale
      // 'loaded' state from a previous session, which would prevent the
      // onboarding gate and itinerary/chat tabs from appearing correctly.
      itineraryCubit.loadUserItinerary();

      // Fallback extra: se já está em error/loaded no momento da montagem,
      // o BlocListener não vai disparar — trata agora.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final state = context.read<ItineraryCubit>().state;
        state.maybeWhen(
          loaded: (group, _, __, pendingDocs) {
            if (_selectedIndex == -1) {
              final now = DateTime.now();
              final endOfDay = DateTime(
                group.endDate.year,
                group.endDate.month,
                group.endDate.day, 23, 59, 59,
              );
              final isActive = endOfDay.isAfter(now) || endOfDay.isAtSameMomentAs(now);
              setState(() => _selectedIndex = isActive ? 0 : 2);
            }
          },
          error: (_) {
            if (_selectedIndex == -1) setState(() => _selectedIndex = 2);
          },
          orElse: () {},
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkFirstAccessPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final show = prefs.getBool('show_first_access_prompt') ?? false;
    if (!show || !mounted) return;
    await prefs.remove('show_first_access_prompt');
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bem-vindo(a)!'),
        content: const Text(
          'Para aproveitar ao máximo a sua viagem, complete seu perfil com '
          'dados pessoais, restrições alimentares e contato de emergência.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/account-data');
            },
            child: const Text('Completar perfil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedCubit>()..loadFeed(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ItineraryCubit, ItineraryState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: (group, _, __, pendingDocs) {
                  final now = DateTime.now();
                  final endOfDay = DateTime(
                    group.endDate.year,
                    group.endDate.month,
                    group.endDate.day,
                    23,
                    59,
                    59,
                  );
                  final isActive =
                      endOfDay.isAfter(now) || endOfDay.isAtSameMomentAs(now);

                  if (_selectedIndex == -1) {
                    setState(() => _selectedIndex = isActive ? 0 : 2);
                  } else if (!isActive &&
                      (_selectedIndex == 0 || _selectedIndex == 1)) {
                    setState(() => _selectedIndex = 2);
                  }
                },
                error: (_) {
                  // Sem missão ou erro: destravar o loading e ir para Comunidade
                  if (_selectedIndex == -1 ||
                      _selectedIndex == 0 ||
                      _selectedIndex == 1) {
                    setState(() => _selectedIndex = 2);
                  }
                },
                orElse: () {},
              );
            },
          ),
        ],
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
            body: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, profileState) {
                final isComplete = profileState.maybeMap(
                  loaded: (s) => s.profile.isComplete,
                  orElse: () => true,
                );

                if (_selectedIndex == -1) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                Widget bodyContent = _buildBody();

                final hasPendingDocs = context.read<DocumentsCubit>().state.hasPendingAction;
                final showProfileBanner = !isComplete && _selectedIndex == 2;
                final showPendingDocsBanner = hasPendingDocs && _selectedIndex == 2;
                final shouldShowBanners = showProfileBanner || showPendingDocsBanner;

                if (shouldShowBanners) {
                  return Stack(
                    children: [
                      bodyContent,
                      Positioned(
                        top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showProfileBanner) ...[
                              const ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                child: IncompleteProfileBanner(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (showPendingDocsBanner)
                              const ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                child: PendingDocumentsBanner(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return bodyContent;
              },
            ),
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
        if (_selectedIndex == 2)
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
        if (_selectedIndex == 0)
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
    if (_selectedIndex == -1) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_selectedIndex == 0) {
      return const ItineraryTab();
    }

    if (_selectedIndex == 1) {
      return const ChatPage();
    }

    if (_selectedIndex == 3) {
      return const ProfileTab();
    }

    return CommunityTab(
      feedWidget: BlocBuilder<FeedCubit, FeedState>(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: EmptyStateWidget(
                        icon: Icons.photo_library_outlined,
                        title: 'Nenhum feed ativo',
                        description: 'Selecione uma missão na aba Início para visualizar e interagir com as publicações.',
                        buttonText: 'Selecionar Missão',
                        onButtonPressed: () {
                          // Se index 0 for Itinerário, mandamos para lá
                          if (context.mounted) {
                            setState(() => _selectedIndex = 0);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              edgeOffset: 120,
              onRefresh: () => context.read<FeedCubit>().loadFeed(),
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8),
                itemCount: posts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                ),
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
                    onProfileTap: () => context.push('/profile/${post.userId}'),
                    onEdit: () async {
                      final result = await context.push<bool>(
                        '/create-post',
                        extra: {
                          'initialImages': post.images,
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
    ));
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
    if (_selectedIndex == -1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ItineraryCubit, ItineraryState>(
      builder: (context, itineraryState) {
        bool showTripTabs = itineraryState.maybeWhen(
          loaded: (group, _, __, ___) {
            final now = DateTime.now();
            final endOfDay = DateTime(
              group.endDate.year,
              group.endDate.month,
              group.endDate.day,
              23,
              59,
              59,
            );
            return endOfDay.isAfter(now) || endOfDay.isAtSameMomentAs(now);
          },
          orElse: () => false,
        );

        return Container(
          padding: EdgeInsets.fromLTRB(
            0,
            10,
            0,
            MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: isDark
                ? Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.1,
                      ),
                      width: 1,
                    ),
                  )
                : null,
            boxShadow: !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (showTripTabs)
                _buildNavItem(
                  0,
                  Icons.explore_outlined,
                  Icons.explore_rounded,
                  'Itinerário',
                ),
              if (showTripTabs)
                _buildNavItem(
                  1,
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                  'Chat',
                ),
              _buildNavItem(
                2,
                Icons.group_outlined,
                Icons.group,
                'Comunidade',
              ),
              BlocBuilder<DocumentsCubit, DocumentsState>(
                builder: (context, state) {
                  return _buildNavItem(
                    3,
                    Icons.badge_outlined,
                    Icons.badge,
                    'Meus dados',
                    hasBadge: state.hasPendingAction,
                  );
                },
              ),
            ],
          ),
        );
      },
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
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 3,
              width: isSelected ? 18.0 : 0.0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
