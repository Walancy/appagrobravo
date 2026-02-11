import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';
import '../../domain/entities/itinerary_item.dart';

class GenericEventCard extends StatelessWidget {
  final ItineraryItemEntity item;
  const GenericEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForType(item.type),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.location != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.location!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.startDateTime != null)
                Text(
                  DateFormat('HH:mm').format(item.startDateTime!),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.description!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.location_on_outlined, size: 16),
              label: const Text('Ver no Mapa'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(ItineraryType type) {
    switch (type) {
      case ItineraryType.food:
        return Icons.restaurant_outlined;
      case ItineraryType.hotel:
        return Icons.hotel_outlined;
      case ItineraryType.visit:
        return Icons.business_outlined;
      case ItineraryType.leisure:
        return Icons.shopping_bag_outlined;
      case ItineraryType.returnType:
        return Icons.keyboard_return;
      default:
        return Icons.event_outlined;
    }
  }
}

class FlightCard extends StatelessWidget {
  final ItineraryItemEntity item;
  const FlightCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 0), // Connected to timeline
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        children: [
          // Header: Airline + Time
          Row(
            children: [
              Icon(
                Icons.airplane_ticket_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voo ${item.name}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.location != null)
                      Text(
                        item.location!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              if (item.endDateTime != null)
                Text(
                  DateFormat('HH:mm').format(item.endDateTime!),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Route: MGF -> GRU
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.fromCode ?? 'ORG',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.flight_takeoff,
                        color: AppColors.primary.withOpacity(0.5),
                        size: 20,
                      ),
                      Container(height: 1, color: Colors.grey.shade200),
                    ],
                  ),
                ),
              ),
              Text(
                item.toCode ?? 'DES',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Times Section
          IntrinsicHeight(
            child: Row(
              children: [
                _buildTimeBlock('Partida', item.startDateTime),
                const VerticalDivider(width: 32, thickness: 1),
                _buildTimeBlock('Chegada', item.endDateTime),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),

          Text(
            'Atualizado há 5 min',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 12),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Ver cartão de embarque',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String label, DateTime? time) {
    if (time == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(DateFormat('HH:mm').format(time), style: AppTextStyles.h2),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terminal',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                ),
                Text(
                  'A7',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portão',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                ),
                Text(
                  '12',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class TransferCard extends StatelessWidget {
  final ItineraryItemEntity item;
  const TransferCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            item.type == ItineraryType.returnType
                ? Icons.keyboard_return
                : Icons.directions_bus_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            item.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (item.startDateTime != null)
            Text(
              DateFormat('HH:mm').format(item.startDateTime!),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class TravelTimeWidget extends StatelessWidget {
  final String duration;
  const TravelTimeWidget({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const SizedBox(width: 4), // 24px - 20px padding
          Container(
            height: 40,
            width: 2,
            child: CustomPaint(
              painter: DashedLinePainter(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 32),
          Text(
            'Tempo de viagem: $duration',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 4), paint);
      startY += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
