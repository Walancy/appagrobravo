import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/chat_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:agrobravo/features/chat/presentation/pages/individual_chat_page.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Scaffold(
          body: state.when(
            initial: () => const ChatShimmer(),
            loading: () => const ChatShimmer(),
            error: (message) => Center(child: Text('Erro: $message')),
            loaded: (data) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  const HeaderSpacer(),
                  if (data.history.isNotEmpty)
                    _buildHistoryTile(context, data),
                  if (data.currentMission != null) ...[
                    _buildSectionLabel(context, context.l10n.chatCurrentMission),
                    _ChatListItem(
                      chat: data.currentMission!,
                      isCurrent: true,
                      lastMessage: data.lastMessages[data.currentMission!.id],
                      lastMessageTime: data.lastMessageTimes[data.currentMission!.id],
                      onReturn: () => context.read<ChatCubit>().loadChatData(),
                    ),
                  ],
                  if (data.guides.isNotEmpty) ...[
                    _buildSectionLabel(context, context.l10n.chatGuides),
                    ...data.guides.map(
                      (g) => _ChatListItem(
                        guide: g,
                        isCurrent: true,
                        lastMessage: data.lastMessages[g.id],
                        lastMessageTime: data.lastMessageTimes[g.id],
                        onReturn: () => context.read<ChatCubit>().loadChatData(),
                      ),
                    ),
                  ],
                  if (data.currentMission == null && data.guides.isEmpty)
                    _buildEmptyState(context),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, dynamic data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    _HistoryPage(
                      historyChats: data.history,
                      lastMessages: data.lastMessages,
                      lastMessageTimes: data.lastMessageTimes,
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 22,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.chatHistoryTileTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        context.l10n.chatHistoryTileSubtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.chatNoActiveMission,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  final List<ChatEntity> historyChats;
  final Map<String, String> lastMessages;
  final Map<String, DateTime> lastMessageTimes;

  const _HistoryPage({
    required this.historyChats,
    required this.lastMessages,
    required this.lastMessageTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.back,
            title: context.l10n.chatHistory,
            subtitle: context.l10n.chatHistorySubtitle,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: [
                if (historyChats.isNotEmpty) ...[
                  _buildSectionLabel(context, context.l10n.chatPrevious),
                  ...historyChats.map(
                    (m) => _ChatListItem(
                      chat: m,
                      isCurrent: false,
                      lastMessage: lastMessages[m.id],
                      lastMessageTime: lastMessageTimes[m.id],
                    ),
                  ),
                ],
                if (historyChats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        context.l10n.chatNoHistory,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatEntity? chat;
  final GuideEntity? guide;
  final bool isCurrent;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final VoidCallback? onReturn;

  const _ChatListItem({
    this.chat,
    this.guide,
    required this.isCurrent,
    this.lastMessage,
    this.lastMessageTime,
    this.onReturn,
  });

  String _formatTime(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0 && now.day == date.day) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 2 && now.day - date.day == 1) {
      return context.l10n.chatYesterday;
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = chat?.title ?? guide?.name ?? '';
    final subtitle = lastMessage ?? chat?.subtitle ?? guide?.role ?? '';
    final imageUrl = chat?.imageUrl ?? guide?.avatarUrl;
    final time = lastMessageTime != null ? _formatTime(context, lastMessageTime!) : '';
    final unreadCount = chat?.unreadCount ?? guide?.unreadCount ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        backgroundImage: imageUrl != null
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl == null
            ? Icon(
                guide != null ? Icons.person_outline_rounded : Icons.group_outlined,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                size: 22,
              )
            : null,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(
            alpha: unreadCount > 0 ? 0.65 : 0.45,
          ),
          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: AppTextStyles.bodySmall.copyWith(
              color: unreadCount > 0
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
              fontSize: 11,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        if (chat != null) {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => ChatDetailPage(chat: chat!),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (guide != null) {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => IndividualChatPage(guide: guide!),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
        onReturn?.call();
      },
    );
  }
}
