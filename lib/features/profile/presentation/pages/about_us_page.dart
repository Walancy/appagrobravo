import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppHeader(mode: HeaderMode.back, title: context.l10n.aboutTitle),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            SvgPicture.asset('assets/images/logo_colorida.svg', height: 100),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                context.l10n.aboutTagline,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildAboutContent(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildValues(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildVersionInfo(context),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            context.l10n.aboutBody1,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.aboutBody2,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValues(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.primary.withOpacity(0.05),
      child: Column(
        children: [
          _buildValueItem(
            context,
            Icons.public,
            context.l10n.aboutValue1Title,
            context.l10n.aboutValue1Sub,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildValueItem(
            context,
            Icons.lightbulb_outline,
            context.l10n.aboutValue2Title,
            context.l10n.aboutValue2Sub,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildValueItem(
            context,
            Icons.groups_outlined,
            context.l10n.aboutValue3Title,
            context.l10n.aboutValue3Sub,
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.aboutAppName,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.aboutVersion,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.aboutCopyright,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
