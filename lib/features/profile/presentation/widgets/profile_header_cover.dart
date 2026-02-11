import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/assets.gen.dart';

class ProfileHeaderCover extends StatelessWidget {
  final String? coverUrl;
  final String? avatarUrl;
  final bool isMe;
  final bool isEditing;
  final VoidCallback? onUpdateAvatar;
  final VoidCallback? onUpdateCover;

  const ProfileHeaderCover({
    super.key,
    this.coverUrl,
    this.avatarUrl,
    this.isMe = false,
    this.isEditing = false,
    this.onUpdateAvatar,
    this.onUpdateCover,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Foto de Capa
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: coverUrl != null
                  ? NetworkImage(coverUrl!)
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

        // Avatar
        Positioned(
          bottom: -50,
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
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.8),
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
