import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onPublish;
  final bool isEditing;
  final bool isMe;
  final ConnectionStatus connectionStatus;
  final VoidCallback? onConnect;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDisconnect;

  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onPublish,
    this.isEditing = false,
    this.isMe = true,
    this.connectionStatus = ConnectionStatus.none,
    this.onConnect,
    this.onCancelRequest,
    this.onAccept,
    this.onReject,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          if (isMe) ...[
            Expanded(
              child: _ProfileActionButton(
                label: isEditing ? 'Cancelar' : 'Editar perfil',
                icon: isEditing ? Icons.close : Icons.edit_outlined,
                backgroundColor: AppColors.primary,
                onPressed: onEditProfile,
              ),
            ),
            if (!isEditing) const SizedBox(width: AppSpacing.sm),
            if (!isEditing)
              Expanded(
                child: _ProfileActionButton(
                  label: 'Publicar',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: onPublish,
                ),
              ),
          ] else ...[
            Expanded(child: _buildConnectionButton()),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionButton() {
    switch (connectionStatus) {
      case ConnectionStatus.none:
        return _ProfileActionButton(
          label: 'Conectar-se',
          icon: Icons.person_add_outlined,
          onPressed: onConnect ?? () {},
        );
      case ConnectionStatus.pendingSent:
        return _ProfileActionButton(
          label: 'Solicitado',
          icon: Icons.hourglass_empty_rounded,
          backgroundColor: Colors.grey[400],
          onPressed: onCancelRequest ?? () {},
        );
      case ConnectionStatus.pendingReceived:
        return Row(
          children: [
            Expanded(
              child: _ProfileActionButton(
                label: 'Aceitar',
                icon: Icons.check,
                onPressed: onAccept ?? () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ProfileActionButton(
                label: 'Recusar',
                icon: Icons.close,
                backgroundColor: Colors.grey[200],
                onPressed: onReject ?? () {},
              ),
            ),
          ],
        );
      case ConnectionStatus.connected:
        return _ProfileActionButton(
          label: 'Desconectar',
          icon: Icons.person_remove_outlined,
          backgroundColor: Colors.grey[200],
          onPressed: onDisconnect ?? () {},
        );
    }
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }
}
