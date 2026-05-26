import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final String title;
  final bool supportFiles;

  const ImageSourceBottomSheet({
    super.key,
    this.title = 'Selecionar imagem',
    this.supportFiles = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: isDark ? 0.16 : 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              supportFiles
                  ? 'Envie um PDF ou capture uma imagem nítida do documento.'
                  : 'Escolha de onde virá a imagem.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.56),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOption(
              context,
              label: supportFiles ? 'Selecionar PDF ou arquivo' : 'Galeria',
              description: supportFiles
                  ? 'Recomendado para documentos já digitalizados.'
                  : 'Escolher uma imagem salva no aparelho.',
              icon: supportFiles
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              onTap: () => Navigator.pop(
                context,
                supportFiles ? 'file' : ImageSource.gallery,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOption(
              context,
              label: 'Tirar foto',
              description: 'Use a câmera para capturar o documento agora.',
              icon: Icons.photo_camera_outlined,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (supportFiles) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildOption(
                context,
                label: 'Escolher imagem',
                description: 'Use uma foto existente da galeria.',
                icon: Icons.image_outlined,
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.onSurface.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.56),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
