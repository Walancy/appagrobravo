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
          loaded: (group, items, _, __) {
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
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 70,
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
                const SizedBox(height: AppSpacing.sm),
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
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
