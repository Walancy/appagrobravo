import 'package:flutter/material.dart';

import 'package:agrobravo/core/tokens/app_text_styles.dart';

class ProfileHeaderStats extends StatelessWidget {
  final int connections;
  final int posts;
  final int missions;
  final VoidCallback? onConnectionsTap;
  final VoidCallback? onPostsTap;
  final VoidCallback? onMissionsTap;

  const ProfileHeaderStats({
    super.key,
    required this.connections,
    required this.posts,
    required this.missions,
    this.onConnectionsTap,
    this.onPostsTap,
    this.onMissionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: onConnectionsTap,
          behavior: HitTestBehavior.opaque,
          child: _buildStatItem(context, '$connections', 'conexões'),
        ),
        GestureDetector(
          onTap: onPostsTap,
          behavior: HitTestBehavior.opaque,
          child: _buildStatItem(context, '$posts', 'Posts'),
        ),
        GestureDetector(
          onTap: onMissionsTap,
          behavior: HitTestBehavior.opaque,
          child: _buildStatItem(context, '$missions', 'Missões'),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(fontSize: 20)),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
