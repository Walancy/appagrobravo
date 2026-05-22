import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String? phone;

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
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          if (isMe) ...[
            Expanded(
              child: _ActionButton(
                label: isEditing ? 'Cancelar' : 'Editar perfil',
                icon: isEditing ? Icons.close_rounded : Icons.edit_outlined,
                style: isEditing ? _ActionStyle.outlined : _ActionStyle.filled,
                onPressed: onEditProfile,
              ),
            ),
            if (!isEditing) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Publicar',
                  icon: Icons.add_circle_outline_rounded,
                  style: _ActionStyle.outlined,
                  onPressed: onPublish,
                ),
              ),
            ],
          ] else ...[
            Expanded(child: _buildConnectionButton(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionButton(BuildContext context) {
    switch (connectionStatus) {
      case ConnectionStatus.none:
        return _ActionButton(
          label: 'Conectar',
          icon: Icons.person_add_outlined,
          style: _ActionStyle.filled,
          onPressed: onConnect ?? () {},
        );

      case ConnectionStatus.pendingSent:
        return _ActionButton(
          label: 'Solicitado',
          icon: Icons.hourglass_empty_rounded,
          style: _ActionStyle.muted,
          onPressed: onCancelRequest ?? () {},
        );

      case ConnectionStatus.pendingReceived:
        return Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Aceitar',
                icon: Icons.check_rounded,
                style: _ActionStyle.filled,
                onPressed: onAccept ?? () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionButton(
                label: 'Recusar',
                icon: Icons.close_rounded,
                style: _ActionStyle.outlined,
                onPressed: onReject ?? () {},
              ),
            ),
          ],
        );

      case ConnectionStatus.connected:
        if (phone != null && phone!.isNotEmpty) {
          return Row(
            children: [
              _ActionButton(
                label: 'WhatsApp',
                icon: Icons.chat_rounded,
                style: _ActionStyle.whatsapp,
                onPressed: () async {
                  final cleanPhone = phone!.replaceAll(RegExp(r'\D'), '');
                  final url = Uri.parse('https://wa.me/55$cleanPhone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Desconectar',
                  icon: Icons.person_remove_outlined,
                  style: _ActionStyle.outlined,
                  onPressed: onDisconnect ?? () {},
                ),
              ),
            ],
          );
        }
        return _ActionButton(
          label: 'Desconectar',
          icon: Icons.person_remove_outlined,
          style: _ActionStyle.outlined,
          onPressed: onDisconnect ?? () {},
        );
    }
  }
}

enum _ActionStyle { filled, outlined, muted, whatsapp }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _ActionStyle style;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (style) {
      case _ActionStyle.filled:
        return SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.button.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        );

      case _ActionStyle.outlined:
        return SizedBox(
          height: 42,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.25 : 0.2),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.button.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        );

      case _ActionStyle.muted:
        return SizedBox(
          height: 42,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.button.copyWith(fontSize: 13),
            ),
          ),
        );

      case _ActionStyle.whatsapp:
        return SizedBox(
          height: 42,
          width: 110,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.button.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        );
    }
  }
}
