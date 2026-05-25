import 'package:flutter/material.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';

class MissionHeaderCard extends StatelessWidget {
  final String missionName;
  final String? groupName;

  const MissionHeaderCard({
    super.key,
    required this.missionName,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.primary.withValues(alpha: 0.15) 
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  groupName!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
