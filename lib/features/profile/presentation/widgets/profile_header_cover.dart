import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/assets.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeaderCover extends StatelessWidget {
  final String? coverUrl;
  final String? avatarUrl;
  final bool isMe;
  final bool isEditing;
  final VoidCallback? onUpdateAvatar;
  final VoidCallback? onUpdateCover;
  final Widget? statsWidget;

  const ProfileHeaderCover({
    super.key,
    this.coverUrl,
    this.avatarUrl,
    this.isMe = false,
    this.isEditing = false,
    this.onUpdateAvatar,
    this.onUpdateCover,
    this.statsWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230, // 180 (cover) + 50 (avatar overflow)
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Foto de Capa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: coverUrl != null
                      ? CachedNetworkImageProvider(coverUrl!)
                      : Assets.images.background.provider(),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  if (isEditing)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _buildCameraButton(onTap: onUpdateCover ?? () {}),
                    ),
                ],
              ),
            ),
          ),

          // Stats
          if (statsWidget != null)
            Positioned(top: 192, left: 136, right: 16, child: statsWidget!),

          // Avatar
          Positioned(
            top: 120, // 180 (cover bottom) - 60 (avatar top portion) = 120
            left: 16,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            fit: BoxFit.cover,
                            height: 110,
                            width: 110,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _buildCameraButton(
                      onTap: onUpdateAvatar ?? () {},
                      backgroundColor: AppColors.primary,
                      iconColor: Colors.white,
                      size: 32,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton({
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black,
    double size = 36,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          color: iconColor,
          size: size * 0.6,
        ),
      ),
    );
  }
}
