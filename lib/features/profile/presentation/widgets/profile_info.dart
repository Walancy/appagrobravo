import 'package:flutter/material.dart';

import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

class ProfileInfo extends StatelessWidget {
  final String name;
  final String? jobTitle;
  final String? bio;
  final String? missionName;
  final String? groupName;

  const ProfileInfo({
    super.key,
    required this.name,
    this.jobTitle,
    this.bio,
    this.missionName,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome
          Text(
            name,
            style: AppTextStyles.h2.copyWith(fontSize: 22),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Nome da Missão e Grupo
          if ((missionName != null && missionName!.isNotEmpty) ||
              (groupName != null && groupName!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 1, bottom: 4),
              child: Text(
                [
                  if (missionName != null && missionName!.isNotEmpty)
                    missionName,
                  if (groupName != null && groupName!.isNotEmpty) groupName,
                ].join(' - '),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Cargo
          if (jobTitle != null && jobTitle!.isNotEmpty)
            Text(
              jobTitle!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: AppSpacing.xs),

          // Bio / Observações
          if (bio != null && bio!.isNotEmpty)
            Text(
              bio!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
