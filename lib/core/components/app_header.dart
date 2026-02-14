import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_state.dart';
import 'package:agrobravo/core/components/scrolling_alert.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:agrobravo/core/cubits/global_alert_cubit.dart';

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
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, docState) {
        return BlocBuilder<GlobalAlertCubit, bool>(
          builder: (context, isDismissed) {
            final hasPending = docState.hasPendingAction;
            final isVisible = hasPending && !isDismissed;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.7),
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
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
                    ),
                  ),
                ),
                if (isVisible)
                  Hero(
                    tag: 'document_scrolling_alert',
                    child: Material(
                      type: MaterialType.transparency,
                      child: ScrollingAlert(
                        text:
                            '⚠️ ATENÇÃO: VOCÊ POSSUI DOCUMENTOS PENDENTES PARA A VIAGEM. CLIQUE AQUI PARA REGULARIZAR.',
                        onTap: () => context.push('/documents'),
                        onClose: () =>
                            context.read<GlobalAlertCubit>().dismiss(),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
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
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, docState) {
        return BlocBuilder<GlobalAlertCubit, bool>(
          builder: (context, isDismissed) {
            final hasPending = docState.hasPendingAction;
            final isVisible = hasPending && !isDismissed;
            return SizedBox(height: isVisible ? 120 : 90);
          },
        );
      },
    );
  }
}
