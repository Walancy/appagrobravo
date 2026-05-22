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
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onConnectionsTap,
            behavior: HitTestBehavior.opaque,
            child: _buildStatItem(context, '$connections', 'conexões'),
          ),
        ),
        _buildDivider(context),
        Expanded(
          child: GestureDetector(
            onTap: onPostsTap,
            behavior: HitTestBehavior.opaque,
            child: _buildStatItem(context, '$posts', 'posts'),
          ),
        ),
        _buildDivider(context),
        Expanded(
          child: GestureDetector(
            onTap: onMissionsTap,
            behavior: HitTestBehavior.opaque,
            child: _buildStatItem(context, '$missions', 'missões'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
