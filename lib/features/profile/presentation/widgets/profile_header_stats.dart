import 'package:flutter/material.dart';

import 'package:agrobravo/core/tokens/app_text_styles.dart';

class ProfileHeaderStats extends StatelessWidget {
  final int connections;
  final int posts;
  final int missions;
  final VoidCallback? onConnectionsTap;

  const ProfileHeaderStats({
    super.key,
    required this.connections,
    required this.posts,
    required this.missions,
    this.onConnectionsTap,
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
        _buildStatItem(context, '$posts', 'Posts'),
        _buildStatItem(context, '$missions', 'Missões'),
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
