import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:intl/intl.dart';

class ItineraryMicrocards extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const ItineraryMicrocards({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryCubit, ItineraryState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (group, items, _) {
            final now = DateTime.now();
            // Filter events from today onwards, or recently passed (last 2 hours)
            final upcomingItems = items
                .where(
                  (item) =>
                      item.startDateTime != null &&
                      item.startDateTime!.isAfter(
                        now.subtract(const Duration(hours: 2)),
                      ),
                )
                .take(5) // Show only the next 5
                .toList();

            if (upcomingItems.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Próximos eventos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: onSeeAll,
                        child: Text(
                          'Itinerário completo',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: upcomingItems.length,
                    itemBuilder: (context, index) {
                      final item = upcomingItems[index];
                      return _buildMicrocard(item);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildMicrocard(ItineraryItemEntity item) {
    IconData icon;
    switch (item.type) {
      case ItineraryType.flight:
        icon = Icons.flight_takeoff_rounded;
        break;
      case ItineraryType.hotel:
        icon = Icons.hotel_rounded;
        break;
      case ItineraryType.food:
        icon = Icons.restaurant_rounded;
        break;
      case ItineraryType.visit:
        icon = Icons.location_on_rounded;
        break;
      case ItineraryType.transfer:
        icon = Icons.directions_bus_rounded;
        break;
      case ItineraryType.leisure:
        icon = Icons.camera_alt_rounded;
        break;
      case ItineraryType.returnType:
        icon = Icons.flight_land_rounded;
        break;
      default:
        icon = Icons.event_note_rounded;
    }

    final time = item.startDateTime != null
        ? DateFormat.Hm().format(item.startDateTime!)
        : '';

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
