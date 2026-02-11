import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrobravo/core/tokens/assets.gen.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:agrobravo/features/chat/presentation/widgets/chat_group_card.dart';
import 'package:agrobravo/features/chat/presentation/widgets/guide_card.dart';
import 'package:agrobravo/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:agrobravo/features/chat/presentation/pages/individual_chat_page.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()..loadChatData(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppHeader(
          mode: HeaderMode.home,
          logo: SvgPicture.asset(Assets.images.logoColorida, height: 32),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text('Erro: $message')),
              loaded: (data) {
                if (data.currentMission == null && data.history.isEmpty) {
                  return const Center(child: Text('Nenhum chat encontrado.'));
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 0,
                  ),
                  children: [
                    const SizedBox(height: 20),

                    if (data.currentMission != null) ...[
                      Text(
                        'Meu Grupo',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildChatCard(
                        context,
                        data.currentMission!,
                        isCurrent: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (data.guides.isNotEmpty) ...[
                      Text(
                        'Guias',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...data.guides.map(
                        (g) => GuideCard(
                          name: g.name,
                          role: g.role,
                          avatarUrl:
                              g.avatarUrl ??
                              'https://i.pravatar.cc/150', // Fallback
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        IndividualChatPage(guide: g),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (data.history.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.history,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Histórico',
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...data.history.map(
                        (m) => _buildChatCard(context, m, isCurrent: false),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatCard(
    BuildContext context,
    ChatEntity mission, {
    required bool isCurrent,
  }) {
    // Basic logic to determine status text for history
    String? status;
    if (!isCurrent) {
      if (mission.endDate != null) {
        status =
            'Encerrado em: ${DateFormat('dd/MM/yyyy').format(mission.endDate!)}';
      } else {
        status = 'Encerrado';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChatDetailPage(chat: mission),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: ChatGroupCard(
        title: mission.title,
        subtitle: mission.subtitle,
        leading: _buildMissionImage(mission.imageUrl),
        time: isCurrent
            ? DateFormat('HH:mm').format(DateTime.now())
            : null, // Mock time for current
        unreadCount: isCurrent ? mission.unreadCount : null,
        statusText: status,
        memberCount: 0, // Not showing as requested
        memberAvatars: const [], // Not fetching members specifically for now
      ),
    );
  }

  Widget _buildMissionImage(String? url) {
    if (url == null || url.isEmpty) {
      return SvgPicture.asset(
        Assets.images.logoColorida,
        width: 30,
        height: 30,
      );
    }
    if (url.endsWith('.svg')) {
      return SvgPicture.network(url, width: 50, height: 50, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.group),
    );
  }
}
