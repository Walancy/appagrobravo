import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
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
  BuildContext context,
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
    if (today.isNotEmpty) _NotificationGroup(context.l10n.notificationsToday, today),
    if (yesterday.isNotEmpty) _NotificationGroup(context.l10n.notificationsYesterday, yesterday),
    if (thisWeek.isNotEmpty) _NotificationGroup(context.l10n.notificationsThisWeek, thisWeek),
    if (older.isNotEmpty) _NotificationGroup(context.l10n.notificationsOlder, older),
  ];
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
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
                title: context.l10n.notificationsTitle,
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
                              label: Text(context.l10n.notificationsMarkAllRead),
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: EmptyStateWidget(
                        icon: Icons.notifications_off_outlined,
                        title: context.l10n.notificationsEmpty,
                        description: context.l10n.notificationsEmptySubtitle,
                      ),
                    );
                  }

                  final groups = _groupNotifications(context, notifications);
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
                                return _NotificationItem(notification: group.items[index]);
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
      tooltip: context.l10n.notificationsClearAllTooltip,
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
            Text(context.l10n.notificationsClearAllTitle, style: const TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          context.l10n.notificationsClearAllConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.commonCancel),
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
            child: Text(context.l10n.notificationsClearAll),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.06),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final currentUserId =
                getIt<FeedRepository>().getCurrentUserId();
            if (currentUserId != null) {
              context.push('/connections/$currentUserId?initialIndex=1');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        context.l10n.notificationsConnectionRequests,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        followRequests.length == 1
                            ? followRequests[0].userName
                            : '${followRequests[0].userName} ${context.l10n.notificationsAndOthers(followRequests.length - 1)}',
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
class _NotificationItem extends StatefulWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {

  bool _expanded = false;
  bool _hasOverflow = false;

  static const int _collapsedMaxLines = 3;

  String _formatTime(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return context.l10n.notificationsJustNow;
    if (diff.inMinutes < 60) return context.l10n.notificationsMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return context.l10n.notificationsHoursAgo(diff.inHours);
    if (diff.inDays == 1) return context.l10n.notificationsYesterdayTime;
    if (diff.inDays < 7) return context.l10n.notificationsDaysAgo(diff.inDays);
    final weeks = (diff.inDays / 7).floor();
    return context.l10n.notificationsWeeksAgo(weeks, weeks > 1 ? 's' : '');
  }

  /// Verifica se o texto transborda além de [_collapsedMaxLines] linhas
  /// no espaço disponível [maxWidth].
  bool _textOverflows(BuildContext context, double maxWidth) {
    final notification = widget.notification;
    final style = AppTextStyles.bodyMedium.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
    final boldStyle = style.copyWith(fontWeight: FontWeight.w700);

    final span = TextSpan(
      style: style,
      children: [
        TextSpan(text: notification.userName, style: boldStyle),
        const TextSpan(text: ' '),
        TextSpan(text: notification.message),
      ],
    );

    final painter = TextPainter(
      text: span,
      maxLines: _collapsedMaxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.primary.withOpacity(0.06))
            : (isDark
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withOpacity(0.2)
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.03)),
        ),
        boxShadow: (isDark || isUnread)
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Leading icon/avatar
            _LeadingWidget(notification: notification),
            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Detecta overflow na primeira renderização
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final overflows = _textOverflows(context, constraints.maxWidth);
                    if (overflows != _hasOverflow) {
                      setState(() => _hasOverflow = overflows);
                    }
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome + mensagem
                      RichText(
                        maxLines: _expanded ? null : _collapsedMaxLines,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
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

                      // Botão Ver mais / Ver menos
                      if (_hasOverflow) ...[
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Text(
                            _expanded ? context.l10n.notificationsSeeLess : context.l10n.notificationsSeeMore,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 5),
                      // Timestamp separado
                      Text(
                        _formatTime(context, notification.createdAt),
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
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // Coluna direita: thumbnail ou badge não-lido + botão Resolver
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                      child: Text(
                        context.l10n.notificationsResolve,
                        style: const TextStyle(
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
            child: Text(
              context.l10n.notificationsAccept,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
            child: Text(
              context.l10n.notificationsReject,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      );
    }

    // Avatar de usuário (follow)
    return CircleAvatar(
      radius: 24,
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
