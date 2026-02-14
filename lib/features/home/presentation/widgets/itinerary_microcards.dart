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
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: 10),
                SizedBox(
                  height: 140, // Reduced height for more compact look
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none, // Correctly shows shadows
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12, // Space for shadows
                    ),
                    itemCount: upcomingItems.length,
                    itemBuilder: (context, index) {
                      final item = upcomingItems[index];
                      return _buildMicrocard(context, item);
                    },
                  ),
                ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildMicrocard(BuildContext context, ItineraryItemEntity item) {
    IconData icon;
    String typeLabel;

    switch (item.type) {
      case ItineraryType.flight:
        icon = Icons.confirmation_number_outlined; // Ticket-like icon
        typeLabel = 'Voo direto';
        break;
      case ItineraryType.hotel:
        icon = Icons.hotel_outlined;
        typeLabel = 'Hospedagem';
        break;
      case ItineraryType.food:
        icon = Icons.restaurant_outlined;
        typeLabel = 'Refeição';
        break;
      case ItineraryType.visit:
        icon = Icons.location_on_outlined;
        typeLabel = 'Visita técnica';
        break;
      case ItineraryType.transfer:
        icon = Icons.directions_bus_outlined;
        typeLabel = 'Transfer';
        break;
      case ItineraryType.leisure:
        icon = Icons.camera_alt_outlined;
        typeLabel = 'Lazer';
        break;
      case ItineraryType.returnType:
        icon = Icons.flight_land_outlined;
        typeLabel = 'Retorno';
        break;
      default:
        icon = Icons.event_available_outlined;
        typeLabel = 'Evento';
    }

    final time = item.startDateTime != null
        ? DateFormat.Hm().format(item.startDateTime!)
        : '--:--';

    return GestureDetector(
      onTap: onSeeAll,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 150, // Smaller width
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10), // Reduced internal padding
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.2
                    : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: const Color(0xFF00AA71)),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppTextStyles.h3.copyWith(
                        color: const Color(0xFF00AA71),
                        fontSize: 14, // Smaller time font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00AA71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Replaced Spacer with small gap
            Text(
              typeLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10, // Smaller type label
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13, // Smaller item name
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.fromCity ?? item.location ?? 'Local não inf.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
