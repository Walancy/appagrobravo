import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/empty_state_widget.dart';
import 'package:agrobravo/core/components/notifications_shimmer.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/profile/presentation/widgets/incomplete_profile_banner.dart';

/// Agrupa notificações por período: Hoje / Ontem / Esta semana / Mais antigas.
class _NotificationGroup {
  final String label;
  final List<NotificationEntity> items;
  _NotificationGroup(this.label, this.items);
}

List<_NotificationGroup> _groupNotifications(
  List<NotificationEntity> notifications,
) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));
  final weekStart = todayStart.subtract(const Duration(days: 7));

  final today = <NotificationEntity>[];
  final yesterday = <NotificationEntity>[];
  final thisWeek = <NotificationEntity>[];
  final older = <NotificationEntity>[];

  for (final n in notifications) {
    final d = n.createdAt;
    if (!d.isBefore(todayStart)) {
      today.add(n);
    } else if (!d.isBefore(yesterdayStart)) {
      yesterday.add(n);
    } else if (!d.isBefore(weekStart)) {
      thisWeek.add(n);
    } else {
      older.add(n);
    }
  }

  return [
    if (today.isNotEmpty) _NotificationGroup('Hoje', today),
    if (yesterday.isNotEmpty) _NotificationGroup('Ontem', yesterday),
    if (thisWeek.isNotEmpty) _NotificationGroup('Últimos 7 dias', thisWeek),
    if (older.isNotEmpty) _NotificationGroup('Mais antigas', older),
  ];
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationsCubit>()..loadNotifications(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final isComplete = profileState.maybeMap(
                loaded: (s) => s.profile.isComplete,
                orElse: () => true,
              );

              final hasUnread = state.maybeWhen(
                loaded: (notifications) => notifications.any((n) => !n.isRead),
                orElse: () => false,
              );

              return Scaffold(
                appBar: AppHeader(
                  mode: HeaderMode.back,
                  title: 'Notificações',
                  actions: [
                    state.maybeWhen(
                      loaded: (notifications) {
                        if (notifications.isEmpty) return const SizedBox.shrink();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasUnread)
                              TextButton.icon(
                                onPressed: () =>
                                    context.read<NotificationsCubit>().markAllAsRead(),
                                icon: const Icon(Icons.done_all_rounded, size: 16),
                                label: const Text('Lidas'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            _ClearAllButton(),
                          ],
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                body: state.when(
                  initial: () => const NotificationsShimmer(),
                  loading: () => const NotificationsShimmer(),
                  error: (message) => Center(child: Text(message)),
                  loaded: (notifications) {
                    if (notifications.isEmpty && isComplete) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyStateWidget(
                          icon: Icons.notifications_off_outlined,
                          title: 'Tudo em dia!',
                          description:
                              'Você não tem nenhuma notificação no momento.',
                        ),
                      );
                    }

                    final groups = _groupNotifications(notifications);
                    final followRequests = notifications
                        .where((n) => n.type == NotificationType.follow)
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<NotificationsCubit>().loadNotifications(),
                      child: CustomScrollView(
                        slivers: [
                          // Banner perfil incompleto
                          if (!isComplete)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: IncompleteProfileBanner(),
                              ),
                            ),

                          // Card de solicitações de conexão agrupadas
                          if (followRequests.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _FollowRequestsSummary(
                                followRequests: followRequests,
                              ),
                            ),

                          // Grupos de notificações
                          for (final group in groups) ...[
                            SliverToBoxAdapter(
                              child: _SectionHeader(label: group.label),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = group.items[index];
                                  final isLast =
                                      index == group.items.length - 1;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _NotificationItem(notification: item),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          indent: 72,
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.6),
                                        ),
                                    ],
                                  );
                                },
                                childCount: group.items.length,
                              ),
                            ),
                          ],

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 40),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Botão "Limpar tudo" com confirmação
// ─────────────────────────────────────────────────────────────
class _ClearAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Limpar notificações',
      icon: const Icon(Icons.delete_sweep_rounded, size: 22),
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      onPressed: () => _confirmClear(context),
    );
  }

  void _confirmClear(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Limpar tudo', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Todas as notificações serão removidas permanentemente. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              cubit.clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Cabeçalho de seção
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card de solicitações de conexão agrupadas
// ─────────────────────────────────────────────────────────────
class _FollowRequestsSummary extends StatelessWidget {
  final List<NotificationEntity> followRequests;
  const _FollowRequestsSummary({required this.followRequests});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            final currentUserId =
                getIt<FeedRepository>().getCurrentUserId();
            if (currentUserId != null) {
              context.push('/connections/$currentUserId?initialIndex=1');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withOpacity(0.06),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                // Avatars empilhados
                SizedBox(
                  width: 48,
                  height: 40,
                  child: Stack(
                    children: [
                      if (followRequests.length > 1)
                        Positioned(
                          left: 16,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                followRequests[1].userAvatar != null
                                ? NetworkImage(followRequests[1].userAvatar!)
                                : null,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.2),
                            child: followRequests[1].userAvatar == null
                                ? const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            followRequests[0].userAvatar != null
                            ? NetworkImage(followRequests[0].userAvatar!)
                            : null,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: followRequests[0].userAvatar == null
                            ? const Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solicitações de conexão',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        followRequests.length == 1
                            ? followRequests[0].userName
                            : '${followRequests[0].userName} e outras ${followRequests.length - 1} pessoas',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${followRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Item de notificação individual
// ─────────────────────────────────────────────────────────────
class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays == 1) return 'ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: () {
        if (isUnread) {
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
          if (notification.postId != null &&
              notification.postOwnerId != null) {
            context.push(
              '/user-feed/${notification.postOwnerId}?postId=${notification.postId}',
            );
          }
        } else if (notification.type == NotificationType.chatMessage) {
          // Navega de volta para a tela de chat
          context.pop();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.04))
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon/avatar
            _LeadingWidget(notification: notification),
            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome + mensagem
                  RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: notification.userName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: notification.message),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Timestamp separado
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isUnread
                          ? AppColors.primary.withOpacity(0.85)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                    ),
                  ),

                  // Ações inline (follow accept/reject)
                  if (notification.type == NotificationType.follow &&
                      isUnread) ...[
                    const SizedBox(height: 8),
                    _FollowActions(notification: notification),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Coluna direita: thumbnail ou badge não-lido + botão Resolver
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (notification.postImage != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      notification.postImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (notification.type == NotificationType.documentRejected ||
                    notification.type ==
                        NotificationType.documentPending) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Resolver',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Ações de follow (aceitar/recusar) inline e compactas
// ─────────────────────────────────────────────────────────────
class _FollowActions extends StatelessWidget {
  final NotificationEntity notification;
  const _FollowActions({required this.notification});

  @override
  Widget build(BuildContext context) {
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
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Aceitar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: () {
              if (notification.solicitacaoUserId != null) {
                context.read<NotificationsCubit>().respondFollowRequest(
                  notification.solicitacaoUserId!,
                  false,
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Recusar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Leading: ícone temático ou avatar
// ─────────────────────────────────────────────────────────────
class _LeadingWidget extends StatelessWidget {
  final NotificationEntity notification;
  const _LeadingWidget({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    Color? bgColor;
    Color iconColor = AppColors.primary;

    switch (notification.type) {
      case NotificationType.documentApproved:
        icon = Icons.check_circle_rounded;
        bgColor = Colors.green.withOpacity(0.12);
        iconColor = Colors.green.shade600;
        break;
      case NotificationType.documentRejected:
        icon = Icons.cancel_rounded;
        bgColor = AppColors.error.withOpacity(0.12);
        iconColor = AppColors.error;
        break;
      case NotificationType.documentPending:
        icon = Icons.pending_rounded;
        bgColor = Colors.orange.withOpacity(0.12);
        iconColor = Colors.orange.shade700;
        break;
      case NotificationType.guideAlert:
        icon = Icons.campaign_rounded;
        bgColor = AppColors.primary.withOpacity(0.12);
        iconColor = AppColors.primary;
        break;
      case NotificationType.missionUpdate:
        icon = Icons.forum_rounded;
        bgColor = AppColors.secondary.withOpacity(0.12);
        iconColor = AppColors.secondary;
        break;
      case NotificationType.like:
        icon = Icons.favorite_rounded;
        bgColor = Colors.pink.withOpacity(0.12);
        iconColor = Colors.pink.shade400;
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble_rounded;
        bgColor = Colors.blue.withOpacity(0.12);
        iconColor = Colors.blue.shade500;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email_rounded;
        bgColor = Colors.purple.withOpacity(0.12);
        iconColor = Colors.purple.shade400;
        break;
      case NotificationType.chatMessage:
        icon = Icons.chat_rounded;
        bgColor = Colors.teal.withOpacity(0.12);
        iconColor = Colors.teal.shade600;
        break;
      default:
        break;
    }

    if (icon != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      );
    }

    // Avatar de usuário (follow)
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            )
          : null,
    );
  }
}
