import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

enum AttachmentType { image, video, file }

class ChatAttachmentBottomSheet extends StatelessWidget {
  final Function(AttachmentType type) onSelect;

  const ChatAttachmentBottomSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text('Enviar anexo', style: AppTextStyles.h3.copyWith(fontSize: 18)),

          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Selecione o tipo de arquivo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOption(
                  label: 'Imagem',
                  icon: Icons.image_outlined,
                  onTap: () => onSelect(AttachmentType.image),
                ),
                const SizedBox(width: AppSpacing.xl),
                _buildOption(
                  label: 'Vídeo',
                  icon: Icons.videocam_outlined,
                  onTap: () => onSelect(AttachmentType.video),
                ),
                const SizedBox(width: AppSpacing.xl),
                _buildOption(
                  label: 'Arquivos',
                  icon: Icons.attach_file_outlined,
                  onTap: () => onSelect(AttachmentType.file),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
