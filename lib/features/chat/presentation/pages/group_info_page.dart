import 'package:agrobravo/core/components/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/chat/presentation/cubit/group_info_cubit.dart';
import 'package:agrobravo/features/chat/presentation/cubit/group_info_state.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/chat/presentation/pages/group_media_page.dart';
import 'package:go_router/go_router.dart';

class GroupInfoPage extends StatelessWidget {
  final ChatEntity chat;

  const GroupInfoPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupInfoCubit>()..loadGroupDetails(chat.id),
      child: _GroupInfoView(chat: chat),
    );
  }
}

class _GroupInfoView extends StatelessWidget {
  final ChatEntity chat;

  const _GroupInfoView({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppHeader(
        mode: HeaderMode.back,
        title: 'Detalhes do grupo',
        subtitle: 'Visualize mais detalhes',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<GroupInfoCubit, GroupInfoState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(
              child: Text(
                'Erro: $msg',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            loaded: (details) {
              final members = details.members;
              final media = details.mediaUrls;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              image: chat.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(chat.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: chat.imageUrl == null
                                ? const Icon(
                                    Icons.group,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            chat.title,
                            style: AppTextStyles.h2.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Missão: ${chat.subtitle}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${members.length} membros',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Media Section
                    if (media.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => GroupMediaPage(mediaUrls: media),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mídias, links e docs',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: media.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              FullScreenMediaPage(
                                                imageUrl: media[index],
                                              ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(media[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Members Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${members.length} membros',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Members List
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    image: member.avatarUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              member.avatarUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                            onError: (_, __) => {},
                                          )
                                        : null,
                                  ),
                                  child: member.avatarUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                title: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${member.name}${member.isMe ? ' (você)' : ''}',
                                        style: AppTextStyles.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (member.isGuide) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00AA6C,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF00AA6C),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          'Guia',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                fontSize: 10,
                                                color: const Color(0xFF00AA6C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  member.role,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: (member.isMe || member.isGuide)
                                    ? null
                                    : _buildConnectionButton(
                                        context,
                                        member,
                                        chat.id,
                                      ),
                                onTap: () =>
                                    context.push('/profile/${member.id}'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConnectionButton(
    BuildContext context,
    GroupMemberEntity member,
    String groupId,
  ) {
    switch (member.connectionStatus) {
      case ConnectionStatus.connected:
        return const Icon(
          Icons.check_circle,
          color: AppColors.primary,
          size: 20,
        );
      case ConnectionStatus.pendingSent:
        return Text(
          'Pendente',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        );
      case ConnectionStatus.pendingReceived:
        return Text(
          'Solicitou',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
        );
      case ConnectionStatus.none:
        return IconButton(
          icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
          onPressed: () {
            context.read<GroupInfoCubit>().requestConnection(
              groupId,
              member.id,
            );
          },
        );
    }
    return const SizedBox.shrink();
  }
}
