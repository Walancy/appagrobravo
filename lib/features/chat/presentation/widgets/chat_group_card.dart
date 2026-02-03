import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

class ChatGroupCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading; // Changed from String imageUrl
  final String? time;
  final int? unreadCount;
  final String? statusText;
  final int memberCount;
  final List<String> memberAvatars;

  const ChatGroupCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    this.time,
    this.unreadCount,
    this.statusText,
    required this.memberCount,
    required this.memberAvatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipOval(child: leading),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (time != null)
                      Text(
                        time!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (statusText != null)
                      Expanded(
                        child: Text(
                          statusText!,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        ),
                      ),
                  ],
                ),

                // Subtitle Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount != null && unreadCount! > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                // Members Avatar Stack removed as requested
                // If we need to put the time/badge here or keep the trailing layout,
                // the current layout has time/badge in the Header Row.
                // The Row removed here was just for avatars (bottom right).
                // So removing it is correct.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
