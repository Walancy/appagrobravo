import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/data/models/travel_guide_models.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/travel_guide_icon_mapper.dart';

/// Widget que exibe um card do Guia de Viagem com:
/// - Ícone + título + badge "Feito" no topo
/// - Descrição HTML renderizada com [HtmlWidget]
/// - Checkbox "Já fiz isso / Estou ciente" no rodapé
class TravelGuideCardWidget extends StatelessWidget {
  final TravelGuideCard card;
  final ValueChanged<bool> onToggle;
  final bool isLoading;

  const TravelGuideCardWidget({
    super.key,
    required this.card,
    required this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecked = card.concluido;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isChecked
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.04))
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isChecked
              ? AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25)
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: isDark ? 0.12 : 0.08),
          width: isChecked ? 1.5 : 1.0,
        ),
        boxShadow: isChecked
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: ícone + título + badge ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    TravelGuideIconMapper.fromName(card.icone),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    card.titulo,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                if (isChecked) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCircular),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Feito',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: textColor.withValues(alpha: isDark ? 0.1 : 0.07),
          ),

          // ── Imagem ───────────────────────────────────────────────────────
          if (card.imagem != null && card.imagem!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Image.network(
                  card.imagem!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // ── Descrição HTML (renderizada de verdade) ───────────────────────
          if (card.descricao.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm + 4,
                AppSpacing.md,
                AppSpacing.sm + 4,
              ),
              child: HtmlWidget(
                card.descricao,
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  color: textColor.withValues(alpha: 0.78),
                  height: 1.6,
                ),
                customStylesBuilder: (element) {
                  // Garante que strong/b ficam em negrito
                  if (element.localName == 'strong' ||
                      element.localName == 'b') {
                    return {'font-weight': 'bold'};
                  }
                  // Garante que em/i ficam em itálico
                  if (element.localName == 'em' ||
                      element.localName == 'i') {
                    return {'font-style': 'italic'};
                  }
                  // Bullets de lista com cor da superfície
                  if (element.localName == 'ul' ||
                      element.localName == 'ol') {
                    return {'padding-left': '16px'};
                  }
                  return null;
                },
              ),
            ),

          // ── Divider ──────────────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: textColor.withValues(alpha: isDark ? 0.1 : 0.07),
          ),

          // ── Checkbox rodapé ───────────────────────────────────────────────
          InkWell(
            onTap: isLoading ? null : () => onToggle(!isChecked),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppSpacing.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color:
                          isChecked ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? AppColors.primary
                            : textColor.withValues(alpha: 0.35),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isChecked
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          )
                        : isChecked
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Text(
                      isChecked
                          ? 'Já fiz isso ✓'
                          : 'Já fiz isso / Estou ciente',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isChecked
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isChecked
                            ? AppColors.primary
                            : textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
