import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_cards.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/widgets/itinerary_filter_modal.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';

class ItineraryList extends StatelessWidget {
  final List<ItineraryItemEntity> items;
  final List<Map<String, dynamic>> travelTimes;
  final DateTime? selectedDate;
  final ItineraryFilters? filters;

  const ItineraryList({
    super.key,
    required this.items,
    required this.travelTimes,
    required this.selectedDate,
    this.filters,
  });

  // Events where showing a "travel time to next" label doesn't make sense.
  static bool _isMovementEvent(ItineraryItemEntity e) =>
      e.type == ItineraryType.flight ||
      e.type == ItineraryType.connection ||
      e.type == ItineraryType.transfer ||
      e.type == ItineraryType.disembark ||
      e.type == ItineraryType.returnType;

  // Tiebreaker used only when two events share the exact same startDateTime.
  static int _typePriority(ItineraryItemEntity e) {
    if (e.type == ItineraryType.disembark) return -1; // just landed → first
    if (e.type == ItineraryType.transfer) return 1;
    if (e.type == ItineraryType.returnType) return 2;  // return → last
    return 0;
  }

  // Sort purely by startDateTime.
  // eventoReferenciaId is used ONLY as a tiebreaker when two events share the
  // exact same time — it never overrides chronological order.
  List<ItineraryItemEntity> _buildOrderedItems(
      List<ItineraryItemEntity> source) {
    final result = List<ItineraryItemEntity>.from(source);

    result.sort((a, b) {
      if (a.startDateTime == null && b.startDateTime == null) return 0;
      if (a.startDateTime == null) return 1;
      if (b.startDateTime == null) return -1;

      final cmp = a.startDateTime!.compareTo(b.startDateTime!);
      if (cmp != 0) return cmp;

      // Same time: if A references B → A comes before B (e.g. transfer → event).
      if (a.eventoReferenciaId != null && a.eventoReferenciaId == b.id) {
        return -1;
      }
      if (b.eventoReferenciaId != null && b.eventoReferenciaId == a.id) {
        return 1;
      }

      return _typePriority(a).compareTo(_typePriority(b));
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      if (selectedDate != null && item.startDateTime != null) {
        if (!_isSameDay(item.startDateTime!, selectedDate!)) return false;
      }
      if (filters != null && filters!.types.isNotEmpty) {
        if (!filters!.types.contains(item.type)) return false;
      }
      if ((filters?.startTime != null || filters?.endTime != null) &&
          item.startDateTime != null) {
        final itemTime = TimeOfDay.fromDateTime(item.startDateTime!);
        final start =
            filters?.startTime ?? const TimeOfDay(hour: 0, minute: 1);
        final end = filters?.endTime ?? const TimeOfDay(hour: 23, minute: 59);
        final itemMinutes = itemTime.hour * 60 + itemTime.minute;
        final startMinutes = start.hour * 60 + start.minute;
        final endMinutes = end.hour * 60 + end.minute;
        if (itemMinutes < startMinutes || itemMinutes > endMinutes) return false;
      }
      return true;
    }).toList();

    final displayedItems = _buildOrderedItems(filteredItems);

    if (displayedItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<ItineraryCubit>().loadUserItinerary();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Text(context.l10n.itineraryEmptyFiltered),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ItineraryCubit>().loadUserItinerary();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: displayedItems.length,
        itemBuilder: (context, index) {
          final item = displayedItems[index];
          final bool isLast = index == displayedItems.length - 1;

          // Status badge
          String? statusLabel;
          Color? statusColor;
          if (item.startDateTime != null) {
            final now = DateTime.now();
            final start = item.startDateTime!;
            final end =
                item.endDateTime ?? start.add(const Duration(hours: 1));
            if (now.isAfter(start) && now.isBefore(end)) {
              statusLabel = context.l10n.itineraryStatusNow;
              statusColor = AppColors.primary;
            } else if (now.isBefore(start) &&
                start.difference(now).inMinutes < 60 &&
                start.day == now.day) {
              statusLabel = context.l10n.itineraryStatusSoon;
              statusColor = Colors.orange;
            }
          }

          // "Dia seguinte" tag: only for transfer pills that cross midnight
          bool showNextDayTag = false;
          if (item.type == ItineraryType.transfer) {
            if (item.isDayAfterTransfer == true) {
              showNextDayTag = true;
            } else if (item.isDayAfterTransfer == null && index > 0) {
              final prev = displayedItems[index - 1];
              if (prev.type == ItineraryType.flight &&
                  prev.startDateTime != null &&
                  item.startDateTime != null &&
                  !_isSameDay(prev.startDateTime!, item.startDateTime!)) {
                showNextDayTag = true;
              }
            }
          }

          // For transfer pills: look up distance from travelTimes using the
          // destination reference (eventoReferenciaId = destination event id).
          String? transferKm;
          if (item.type == ItineraryType.transfer &&
              item.eventoReferenciaId != null) {
            try {
              final travel = travelTimes.firstWhere(
                (t) => t['id_destino'].toString() == item.eventoReferenciaId,
              );
              final raw = travel['distancia']?.toString() ??
                  travel['distance_text']?.toString() ??
                  travel['distance']?.toString();
              if (raw != null && raw.isNotEmpty) transferKm = raw;
            } catch (_) {}
          }

          Widget card;
          if (item.type == ItineraryType.flight ||
              item.type == ItineraryType.connection) {
            card = FlightCard(item: item);
          } else if (item.type == ItineraryType.transfer ||
              item.type == ItineraryType.disembark ||
              item.type == ItineraryType.returnType) {
            card = TransferCard(
              item: item,
              showNextDayTag: showNextDayTag,
              distancia: transferKm,
            );
          } else {
            card = GenericEventCard(item: item);
          }

          if (statusLabel != null) {
            card = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8, left: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          // Travel time: only between two non-movement activity events.
          // Flights, transfers, disembarks and returns handle their own context.
          String? travelDuration;
          if (!_isMovementEvent(item) && !isLast) {
            final nextItem = displayedItems[index + 1];
            if (!_isMovementEvent(nextItem)) {
              final raw = nextItem.travelTime;
              if (raw != null && raw.isNotEmpty) {
                travelDuration = raw;
              } else {
                try {
                  final travel = travelTimes.firstWhere(
                    (t) =>
                        t['id_origem'].toString() == item.id &&
                        t['id_destino'].toString() == nextItem.id,
                  );
                  final v = travel['tempo_deslocamento']?.toString();
                  if (v != null && v.isNotEmpty) travelDuration = v;
                } catch (_) {}
              }
            }
          }

          return Stack(
            children: [
              if (!isLast)
                Positioned(
                  left: 30,
                  top: 50,
                  bottom: -2,
                  child: SizedBox(
                    width: 2,
                    child: CustomPaint(
                      painter: DashedLineVerticalPainter(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              Column(
                children: [
                  card,
                  if (travelDuration != null)
                    TravelTimeWidget(duration: travelDuration)
                  else if (!isLast)
                    const SizedBox(height: 12),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
