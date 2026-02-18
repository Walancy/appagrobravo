import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/profile/presentation/widgets/profile_header_cover.dart';
import 'package:agrobravo/features/profile/presentation/widgets/profile_header_stats.dart';
import 'package:agrobravo/features/profile/presentation/widgets/profile_info.dart';
import 'package:agrobravo/features/profile/presentation/widgets/profile_actions.dart';
import 'package:agrobravo/features/profile/presentation/widgets/profile_post_grid.dart';
import 'package:agrobravo/features/home/presentation/widgets/new_post_bottom_sheet.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/image_source_bottom_sheet.dart';
import 'package:agrobravo/core/components/profile_shimmer.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

class ProfileTab extends StatefulWidget {
  final String? userId;
  const ProfileTab({super.key, this.userId});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _postsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPosts() {
    if (_postsKey.currentContext != null) {
      Scrollable.ensureVisible(
        _postsKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showMissionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Minhas Missões', style: AppTextStyles.h3),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<dartz.Either<Exception, List<MissionEntity>>>(
                future: getIt<FeedRepository>().getUserMissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final result = snapshot.data;
                  final missions =
                      result?.fold((l) => <MissionEntity>[], (r) => r) ?? [];

                  if (missions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma missão encontrada',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: missions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final mission = missions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: mission.logo != null
                                  ? CachedNetworkImage(
                                      imageUrl: mission.logo!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Icon(
                                        Icons.flag,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mission.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Add dates if available in MissionEntity?
                                  // MissionEntity usually has date range?
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(widget.userId),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: widget.userId != null
            ? const AppHeader(mode: HeaderMode.back, title: 'Perfil')
            : null,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const ProfileShimmer(),
              error: (message) => Center(child: Text(message)),
              loaded: (profile, posts, isMe, isEditing) {
                Future<void> pickAndUploadImage(bool isAvatar) async {
                  final picker = ImagePicker();
                  final source = await showModalBottomSheet<ImageSource>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ImageSourceBottomSheet(
                      title: isAvatar
                          ? 'Alterar foto de perfil'
                          : 'Alterar capa',
                    ),
                  );

                  if (source != null) {
                    final image = await picker.pickImage(source: source);
                    if (image != null && context.mounted) {
                      if (isAvatar) {
                        context.read<ProfileCubit>().updateProfilePhoto(image);
                      } else {
                        context.read<ProfileCubit>().updateCoverPhoto(image);
                      }
                    }
                  }
                }

                Future<void> handleNewPost(BuildContext context) async {
                  final picker = ImagePicker();
                  final isCamera = await showModalBottomSheet<bool>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => NewPostBottomSheet(
                      onSourceSelected: (camera) =>
                          Navigator.pop(context, camera),
                    ),
                  );

                  if (isCamera != null) {
                    final source = isCamera
                        ? ImageSource.camera
                        : ImageSource.gallery;
                    try {
                      final image = await picker.pickImage(source: source);
                      if (image != null && context.mounted) {
                        final result = await context.push<bool>(
                          '/create-post',
                          extra: [image],
                        );
                        if (result == true && context.mounted) {
                          context.read<ProfileCubit>().loadProfile();
                        }
                      }
                    } catch (_) {}
                  }
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeaderSpacer(),
                      ProfileHeaderCover(
                        coverUrl: profile.coverUrl,
                        avatarUrl: profile.avatarUrl,
                        isMe: isMe,
                        isEditing: isEditing,
                        onUpdateAvatar: () => pickAndUploadImage(true),
                        onUpdateCover: () => pickAndUploadImage(false),
                        statsWidget: Opacity(
                          opacity: isEditing ? 0.3 : 1.0,
                          child: ProfileHeaderStats(
                            connections: profile.connectionsCount,
                            posts: profile.postsCount,
                            missions: profile.missionsCount,
                            onConnectionsTap: () {
                              context.push('/connections/${profile.id}');
                            },
                            onPostsTap: _scrollToPosts,
                            onMissionsTap: _showMissionsModal,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Opacity(
                        opacity: isEditing ? 0.3 : 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileInfo(
                              name: profile.name,
                              jobTitle: profile.jobTitle,
                              bio: profile.bio,
                              missionName: profile.missionName,
                              groupName: profile.groupName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProfileActions(
                        isMe: isMe,
                        connectionStatus: profile.connectionStatus,
                        onConnect: () => context
                            .read<ProfileCubit>()
                            .requestConnection(profile.id),
                        onCancelRequest: () => context
                            .read<ProfileCubit>()
                            .cancelConnection(profile.id),
                        onAccept: () => context
                            .read<ProfileCubit>()
                            .acceptConnection(profile.id),
                        onReject: () => context
                            .read<ProfileCubit>()
                            .rejectConnection(profile.id),
                        onDisconnect: () => context
                            .read<ProfileCubit>()
                            .removeConnection(profile.id),
                        onEditProfile: () =>
                            context.read<ProfileCubit>().toggleEditing(),
                        onPublish: () => handleNewPost(context),
                        isEditing: isEditing,
                        phone: profile.phone,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Opacity(
                        key: _postsKey,
                        opacity: isEditing ? 0.3 : 1.0,
                        child: ProfilePostGrid(posts: posts),
                      ),
                      const SizedBox(height: 80),
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
}
