import 'package:flutter/material.dart';
import '../../domain/entities/itinerary_item.dart';
import 'itinerary_cards.dart';

class ItineraryList extends StatelessWidget {
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;
  final DateTime? selectedDate;

  const ItineraryList({
    super.key,
    required this.items,
    required this.travelTimes,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items
    final displayedItems = items.where((item) {
      if (selectedDate == null) return true;
      if (item.startDateTime == null) return false;
      return _isSameDay(item.startDateTime!, selectedDate!);
    }).toList();

    // Sort: por horário, e se for igual, transfer fica por último
    displayedItems.sort((a, b) {
      if (a.startDateTime == null || b.startDateTime == null) return 0;

      final dateCompare = a.startDateTime!.compareTo(b.startDateTime!);
      if (dateCompare != 0) return dateCompare;

      // Se o horário for igual, tipos 'transfer' ou 'returnType' devem vir depois dos outros
      final bool isAExtra =
          a.type == ItineraryType.transfer ||
          a.type == ItineraryType.returnType;
      final bool isBExtra =
          b.type == ItineraryType.transfer ||
          b.type == ItineraryType.returnType;

      if (isAExtra && !isBExtra) return 1;
      if (!isAExtra && isBExtra) return -1;

      return 0;
    });

    if (displayedItems.isEmpty) {
      return const Center(
        child: Text("Nenhum evento verificado para este dia."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: displayedItems.length,
      itemBuilder: (context, index) {
        final item = displayedItems[index];
        final bool isLast = index == displayedItems.length - 1;
        final bool isExtra =
            item.type == ItineraryType.transfer ||
            item.type == ItineraryType.returnType;
        final bool nextIsExtra =
            !isLast &&
            (displayedItems[index + 1].type == ItineraryType.transfer ||
                displayedItems[index + 1].type == ItineraryType.returnType);

        Widget card;
        if (item.type == ItineraryType.flight) {
          card = FlightCard(item: item);
        } else if (item.type == ItineraryType.transfer) {
          card = TransferCard(item: item);
        } else {
          card = GenericEventCard(item: item);
        }

        // Try to find travel time:
        // We look for the travel time to reach the NEXT item
        String? travelDuration;

        final bool nextIsTransfer =
            !isLast && displayedItems[index + 1].type == ItineraryType.transfer;

        if (!isLast && !nextIsTransfer) {
          final nextItem = displayedItems[index + 1];
          // Prioritize the property in the next item (displacement TO that item)
          travelDuration = nextItem.travelTime;

          // Fallback to the pair-matching logic
          if (travelDuration == null || travelDuration.isEmpty) {
            try {
              final travel = travelTimes.firstWhere(
                (t) =>
                    t['id_origem'] == item.id && t['id_destino'] == nextItem.id,
              );
              travelDuration = travel['tempo_deslocamento'];
            } catch (_) {}
          }
        }

        return Stack(
          children: [
            // Timeline line
            if (!isLast)
              Positioned(
                left: 24, // Matches icon center in card
                top: 50,
                bottom: -2,
                child: Container(
                  width: 2,
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Background
                  ),
                  child: CustomPaint(
                    painter: DashedLineVerticalPainter(
                      color: const Color(0xFF00BFA5),
                    ), // Use Primary Green
                  ),
                ),
              ),

            Column(
              children: [
                card,
                if (travelDuration != null)
                  TravelTimeWidget(duration: travelDuration),
                if (!isLast &&
                    travelDuration == null &&
                    !isExtra &&
                    !nextIsExtra)
                  const SizedBox(height: 20),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  final Color color;
  DashedLineVerticalPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dash height 5, space 3
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 5), paint);
      startY += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
