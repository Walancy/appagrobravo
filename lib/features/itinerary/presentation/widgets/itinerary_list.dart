import 'package:flutter/material.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../../../core/tokens/app_colors.dart';
import 'itinerary_cards.dart';

import 'itinerary_filter_modal.dart';

class ItineraryList extends StatelessWidget {
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;
  final DateTime? selectedDate;
  final ItineraryFilters? filters;
  final List<String> pendingDocs;

  const ItineraryList({
    super.key,
    required this.items,
    required this.travelTimes,
    required this.selectedDate,
    this.filters,
    this.pendingDocs = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Filter items
    final displayedItemsFull = items.where((item) {
      // 1. Filter by Date (Priority to filter.date, fallback to selectedDate)
      final filterDate = filters?.date ?? selectedDate;
      if (filterDate != null && item.startDateTime != null) {
        if (!_isSameDay(item.startDateTime!, filterDate)) return false;
      }

      // 2. Filter by Type
      if (filters != null && filters!.types.isNotEmpty) {
        if (!filters!.types.contains(item.type)) return false;
      }

      // 3. Filter by Time
      if (filters?.startTime != null && item.startDateTime != null) {
        final itemTime = TimeOfDay.fromDateTime(item.startDateTime!);
        if (itemTime.hour < filters!.startTime!.hour) return false;
        if (itemTime.hour == filters!.startTime!.hour &&
            itemTime.minute < filters!.startTime!.minute)
          return false;
      }

      return true;
    }).toList();

    // 1. Sort the FULL filtered list
    final displayedItems = List<ItineraryItemEntity>.from(displayedItemsFull);
    displayedItems.sort(_sortLogic);

    // Filter items for logical neighbors logic needs the FULL sorted list
    final fullItemsSorted = List<ItineraryItemEntity>.from(items);
    fullItemsSorted.sort(_sortLogic);

    if (displayedItems.isEmpty) {
      return const Center(
        child: Text("Nenhum evento corresponde aos filtros."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: displayedItems.length,
      itemBuilder: (context, index) {
        final item = displayedItems[index];
        final bool isLast = index == displayedItems.length - 1;
        final bool nextIsExtra =
            !isLast &&
            (displayedItems[index + 1].type == ItineraryType.transfer ||
                displayedItems[index + 1].type == ItineraryType.returnType);

        // Determine if we should show the "Next day" tag
        bool showNextDayTag = false;
        if (item.type == ItineraryType.transfer) {
          final globalIndex = fullItemsSorted.indexOf(item);
          if (globalIndex > 0) {
            final prevItem = fullItemsSorted[globalIndex - 1];
            // If it follows a flight from a different day
            if (prevItem.type == ItineraryType.flight &&
                prevItem.startDateTime != null &&
                item.startDateTime != null &&
                !_isSameDay(prevItem.startDateTime!, item.startDateTime!)) {
              showNextDayTag = true;
            }
          }
        }

        Widget card;

        // Determine status
        String? statusLabel;
        Color? statusColor;

        if (item.startDateTime != null) {
          final now = DateTime.now();
          final start = item.startDateTime!;
          // Approx end if not set (1 hour)
          final end = item.endDateTime ?? start.add(const Duration(hours: 1));

          if (now.isAfter(start) && now.isBefore(end)) {
            statusLabel = 'Acontecendo agora';
            statusColor = AppColors.primary;
          } else if (now.isBefore(start) &&
              start.difference(now).inMinutes < 60 &&
              start.day == now.day) {
            statusLabel = 'Em breve';
            statusColor = Colors.orange;
          }
        }

        if (item.type == ItineraryType.flight) {
          card = FlightCard(item: item, pendingDocs: pendingDocs);
        } else if (item.type == ItineraryType.transfer) {
          card = TransferCard(item: item, showNextDayTag: showNextDayTag);
        } else {
          card = GenericEventCard(item: item);
        }

        if (statusLabel != null) {
          card = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                  left: 20,
                ), // Indent to align with content
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              card,
            ],
          );
        }

        // Try to find travel time:
        String? travelDuration;

        if (item.type == ItineraryType.transfer) {
          travelDuration =
              (item.travelTime != null && item.travelTime!.isNotEmpty)
              ? item.travelTime
              : item.durationString;
        } else {
          final bool nextIsTransfer =
              !isLast &&
              displayedItems[index + 1].type == ItineraryType.transfer;

          if (!isLast && !nextIsTransfer) {
            final nextItem = displayedItems[index + 1];
            travelDuration = nextItem.travelTime;

            if (travelDuration == null || travelDuration.isEmpty) {
              try {
                final travel = travelTimes.firstWhere(
                  (t) =>
                      t['id_origem'].toString() == item.id.toString() &&
                      t['id_destino'].toString() == nextItem.id.toString(),
                );
                travelDuration = travel['tempo_deslocamento'];
              } catch (_) {}
            }
          }
        }

        return Stack(
          children: [
            // Timeline line
            if (!isLast)
              Positioned(
                left:
                    30, // Alinhado com o centro do ícone (20 padding + 20/2 tamanho)
                top: 50,
                bottom: -2,
                child: Container(
                  width: 2,
                  child: CustomPaint(
                    painter: DashedLineVerticalPainter(
                      color: const Color(0xFF00BFA5).withOpacity(0.5),
                    ),
                  ),
                ),
              ),

            Column(
              children: [
                card,
                if (travelDuration != null)
                  TravelTimeWidget(duration: travelDuration),
                if (!isLast && travelDuration == null && !nextIsExtra)
                  const TravelTimeWidget(duration: null),
                if (!isLast && travelDuration == null && nextIsExtra)
                  const SizedBox(height: 10),
              ],
            ),
          ],
        );
      },
    );
  }

  int _sortLogic(ItineraryItemEntity a, ItineraryItemEntity b) {
    if (a.startDateTime == null || b.startDateTime == null) return 0;
    final dateCompare = a.startDateTime!.compareTo(b.startDateTime!);
    if (dateCompare != 0) return dateCompare;

    final bool isAExtra =
        a.type == ItineraryType.transfer || a.type == ItineraryType.returnType;
    final bool isBExtra =
        b.type == ItineraryType.transfer || b.type == ItineraryType.returnType;

    if (isAExtra && !isBExtra) return 1;
    if (!isAExtra && isBExtra) return -1;
    return 0;
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

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 5), paint);
      startY += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
