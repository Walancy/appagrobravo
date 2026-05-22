import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

enum HeaderMode { home, back }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final HeaderMode mode;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? logo;
  final VoidCallback? onTitleTap;

  const AppHeader({
    super.key,
    required this.mode,
    this.title,
    this.subtitle,
    this.actions,
    this.logo,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderBackground(context),
      ],
    );
  }

  Widget _buildHeaderBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inner = Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.85)
            : Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: isDark ? 0.1 : 0.07,
            ),
            width: 0.5,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            10,
          ),
          child: _buildContent(context),
        ),
      ),
    );

    if (isDark) {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: inner,
        ),
      );
    }

    return inner;
  }

  Widget _buildContent(BuildContext context) {
    if (mode == HeaderMode.home) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          logo ?? const SizedBox.shrink(),
          if (actions != null) Row(children: actions!),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        if (logo != null) ...[const SizedBox(width: AppSpacing.sm), logo!],
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: onTitleTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        if (actions != null) Row(children: actions!),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90); // Constant base size
}

class HeaderSpacer extends StatelessWidget {
  const HeaderSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 90);
  }
}
