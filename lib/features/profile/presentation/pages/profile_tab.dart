import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:go_router/go_router.dart';

import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/image_source_bottom_sheet.dart';
import 'package:agrobravo/core/components/profile_shimmer.dart';

class ProfileTab extends StatelessWidget {
  final String? userId;
  const ProfileTab({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(userId),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: userId != null
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

                Future<void> _handleNewPost(BuildContext context) async {
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
                        onPublish: () => _handleNewPost(context),
                        isEditing: isEditing,
                        phone: profile.phone,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Opacity(
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
