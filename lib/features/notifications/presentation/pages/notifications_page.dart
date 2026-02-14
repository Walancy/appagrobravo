import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationsCubit>()..loadNotifications(),
      child: Scaffold(
        appBar: const AppHeader(mode: HeaderMode.back, title: 'Notificações'),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text(message)),
              loaded: (notifications) {
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma notificação encontrada'),
                  );
                }

                final last7Days = notifications
                    .where(
                      (n) => n.createdAt.isAfter(
                        DateTime.now().subtract(const Duration(days: 7)),
                      ),
                    )
                    .toList();

                final last30Days = notifications
                    .where(
                      (n) =>
                          n.createdAt.isAfter(
                            DateTime.now().subtract(const Duration(days: 30)),
                          ) &&
                          !last7Days.contains(n),
                    )
                    .toList();

                final older = notifications
                    .where(
                      (n) => !last7Days.contains(n) && !last30Days.contains(n),
                    )
                    .toList();

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<NotificationsCubit>().loadNotifications(),
                  child: ListView(
                    children: [
                      _buildFollowRequestsSummary(context, notifications),
                      _buildAllCaughtUpHeader(context, notifications),

                      if (last7Days.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Últimos 7 dias'),
                        ...last7Days.map(
                          (item) => _NotificationItem(notification: item),
                        ),
                      ],

                      if (last30Days.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Últimos 30 dias'),
                        ...last30Days.map(
                          (item) => _NotificationItem(notification: item),
                        ),
                      ],

                      if (older.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Mais antigas'),
                        ...older.map(
                          (item) => _NotificationItem(notification: item),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowRequestsSummary(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    // Check for follow notifications that are not responded yet
    // For now, using the mock design but we'd filter by type
    final followRequests = notifications
        .where((n) => n.type == NotificationType.follow)
        .toList();
    if (followRequests.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        final currentUserId = getIt<FeedRepository>().getCurrentUserId();
        if (currentUserId != null) {
          context.push('/connections/$currentUserId?initialIndex=1');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: followRequests[0].userAvatar != null
                      ? NetworkImage(followRequests[0].userAvatar!)
                      : null,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.backgroundLight,
                  child: followRequests[0].userAvatar == null
                      ? Icon(
                          Icons.person,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                if (followRequests.length > 1)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: followRequests[1].userAvatar != null
                            ? NetworkImage(followRequests[1].userAvatar!)
                            : null,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.backgroundLight,
                        child: followRequests[1].userAvatar == null
                            ? Icon(
                                Icons.person,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitações de conexão',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${followRequests[0].userName}${followRequests.length > 1 ? ' + outras ${followRequests.length - 1} contas' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCaughtUpHeader(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    if (unreadCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Icon(
                Icons.check,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tudo atualizado',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Você viu todas as notificações',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.h3.copyWith(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks sem';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsCubit>().markAsRead(notification.id);
        }

        if (notification.type == NotificationType.follow) {
          final currentUserId = getIt<FeedRepository>().getCurrentUserId();
          if (currentUserId != null) {
            context.push('/connections/$currentUserId?initialIndex=1');
          }
        } else if (notification.type == NotificationType.like ||
            notification.type == NotificationType.comment ||
            notification.type == NotificationType.mention) {
          if (notification.postId != null && notification.postOwnerId != null) {
            context.push(
              '/user-feed/${notification.postOwnerId}?postId=${notification.postId}',
            );
          }
        }
      },
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            _buildLeading(context),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: notification.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: notification.message),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: _formatTime(notification.createdAt),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    IconData? icon;
    Color? bgColor;
    Color iconColor = AppColors.primary;

    switch (notification.type) {
      case NotificationType.documentApproved:
        icon = Icons.check_circle_rounded;
        bgColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        break;
      case NotificationType.documentRejected:
      case NotificationType.documentPending:
        icon = Icons.error_rounded;
        bgColor = AppColors.error.withOpacity(0.1);
        iconColor = AppColors.error;
        break;
      case NotificationType.guideAlert:
        icon = Icons.campaign_rounded;
        bgColor = AppColors.primary.withOpacity(0.1);
        iconColor = AppColors.primary;
        break;
      case NotificationType.missionUpdate:
        icon = Icons.explore_rounded;
        bgColor = AppColors.secondary.withOpacity(0.1);
        iconColor = AppColors.secondary;
        break;
      default:
        break;
    }

    if (icon != null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: bgColor,
        child: Icon(icon, color: iconColor, size: 24),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundImage: notification.userAvatar != null
          ? NetworkImage(notification.userAvatar!)
          : null,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.backgroundLight,
      child: notification.userAvatar == null
          ? Icon(
              Icons.person,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            )
          : null,
    );
  }

  Widget _buildAction(BuildContext context) {
    if (notification.type == NotificationType.documentRejected ||
        notification.type == NotificationType.documentPending) {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Resolver',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (notification.type == NotificationType.follow && !notification.isRead) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                if (notification.solicitacaoUserId != null) {
                  context.read<NotificationsCubit>().respondFollowRequest(
                    notification.solicitacaoUserId!,
                    true,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Aceitar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {
              if (notification.solicitacaoUserId != null) {
                context.read<NotificationsCubit>().respondFollowRequest(
                  notification.solicitacaoUserId!,
                  false,
                );
              }
            },
          ),
        ],
      );
    }

    if (notification.postImage != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(notification.postImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
