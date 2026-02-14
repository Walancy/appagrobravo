import 'package:agrobravo/core/components/app_header.dart'; // Re-added for HeaderSpacer and AppHeader
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
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
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()..loadChatData(),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text('Erro: $message')),
              loaded: (data) {
                // Active chats: Only Current Mission
                final activeChats = <Widget>[];

                // History Row
                activeChats.add(
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text(
                      'Histórico',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  _HistoryPage(
                                    historyChats: data.history,
                                    guideChats: data.guides,
                                  ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                );

                if (data.currentMission != null) {
                  activeChats.add(
                    _WhatsAppListItem(
                      context: context,
                      chat: data.currentMission!,
                      isCurrent: true,
                    ),
                  );
                }

                // If there are no active mission, maybe show a message?
                // For now, if currentMission is null, the list only has History Row.

                return SafeArea(child: ListView(children: activeChats));
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  final List<ChatEntity> historyChats;
  final List<GuideEntity> guideChats;

  const _HistoryPage({required this.historyChats, required this.guideChats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.back,
            title: 'Histórico',
            subtitle: 'Todas as conversas',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (guideChats.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Guias',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...guideChats.map(
                    (g) => _WhatsAppListItem(
                      context: context,
                      guide: g,
                      isCurrent: true,
                    ),
                  ),
                ],
                if (historyChats.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Antigos',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...historyChats.map(
                    (m) => _WhatsAppListItem(
                      context: context,
                      chat: m,
                      isCurrent: false,
                    ),
                  ),
                ],
                if (guideChats.isEmpty && historyChats.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Nenhum histórico encontrado'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppListItem extends StatelessWidget {
  final BuildContext context;
  final ChatEntity? chat;
  final GuideEntity? guide;
  final bool isCurrent;

  const _WhatsAppListItem({
    required this.context,
    this.chat,
    this.guide,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final title = chat?.title ?? guide?.name ?? '';
    final subtitle = chat?.subtitle ?? guide?.role ?? '';
    final imageUrl = chat?.imageUrl ?? guide?.avatarUrl;
    final time = isCurrent
        ? DateFormat('HH:mm').format(DateTime.now())
        : '--:--';
    final unreadCount = chat?.unreadCount ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Icon(
                guide != null ? Icons.person : Icons.group,
                color: Colors.grey,
              )
            : null,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
              color: unreadCount > 0 ? AppColors.primary : Colors.grey,
              fontSize: 10,
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
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        if (chat != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ChatDetailPage(chat: chat!),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (guide != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => IndividualChatPage(guide: guide!),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
    );
  }
}
