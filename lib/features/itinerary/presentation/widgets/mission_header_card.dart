import 'package:flutter/material.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';

class MissionHeaderCard extends StatelessWidget {
  final String missionName;
  final String? groupName;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onTravelDataTap;

  const MissionHeaderCard({
    super.key,
    required this.missionName,
    this.groupName,
    required this.startDate,
    required this.endDate,
    this.onTravelDataTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    String daysLabel = '';
    String daysValue = '';
    bool showDaysCard = false;

    if (start.year > 0) {
      if (today.isBefore(start)) {
        daysValue = start.difference(today).inDays.toString();
        daysLabel = context.l10n.itineraryMissionStartsIn;
        showDaysCard = true;
      } else if (!today.isAfter(end)) {
        final diff = end.difference(today).inDays;
        daysValue = diff.toString();
        daysLabel = diff == 0 ? context.l10n.itineraryMissionEndsToday : context.l10n.itineraryMissionEndsIn;
        showDaysCard = true;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      missionName,
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    if (groupName != null && groupName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              groupName!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showDaysCard)
                Container(
                  width: 70,
                  margin: const EdgeInsets.only(left: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        daysLabel,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (daysValue != '0' || !daysLabel.contains('\n'))
                        Text(
                          daysValue,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            height: 1.0,
                          ),
                        ),
                      if (daysValue != '0' || !daysLabel.contains('\n'))
                        Text(
                          context.l10n.itineraryMissionDays,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          if (onTravelDataTap != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: TextButton.icon(
                onPressed: onTravelDataTap,
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: Text(context.l10n.itineraryTravelData),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
