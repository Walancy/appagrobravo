import 'package:flutter/material.dart';
import '../../domain/entities/itinerary_item.dart';
import 'itinerary_cards.dart';

class ItineraryList extends StatelessWidget {
  final List<ItineraryItemEntity> items;
  final DateTime? selectedDate;

  const ItineraryList({
    super.key,
    required this.items,
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

    // Sort
    displayedItems.sort((a, b) {
      if (a.startDateTime == null || b.startDateTime == null) return 0;
      return a.startDateTime!.compareTo(b.startDateTime!);
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

        Widget card;
        if (item.type == ItineraryType.flight) {
          card = FlightCard(item: item);
        } else if (item.type == ItineraryType.transfer) {
          card = TransferCard(item: item);
        } else {
          card = GenericEventCard(item: item);
        }

        // Check if next item implies a travel time or just spacing
        final bool isLast = index == displayedItems.length - 1;

        // Custom widget for timeline line
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
                  decoration: BoxDecoration(
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
                // If transfer, show travel time
                if (item.type == ItineraryType.transfer &&
                    !isLast &&
                    item.durationString != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 48), // Indent past line
                    child: Text(
                      "Tempo de viagem: ${item.durationString}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                else
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
