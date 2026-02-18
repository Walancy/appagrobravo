import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/tokens/app_colors.dart';
import '../../../../core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:url_launcher/url_launcher.dart';

class GenericEventCard extends StatelessWidget {
  final ItineraryItemEntity item;
  const GenericEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item.type == ItineraryType.hotel) ...[
                          if (item.name.toLowerCase().contains('check-in') ||
                              (item.description?.toLowerCase().contains(
                                    'check-in',
                                  ) ??
                                  false))
                            _buildHotelTag('CHECK-IN', Colors.blue),
                          if (item.name.toLowerCase().contains('check-out') ||
                              (item.description?.toLowerCase().contains(
                                    'check-out',
                                  ) ??
                                  false))
                            _buildHotelTag('CHECK-OUT', Colors.orange),
                        ],
                      ],
                    ),
                    if (item.location != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.location!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.6)
                              .withOpacity(0.7),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                if (item.location != null && item.location!.isNotEmpty) {
                  final query = Uri.encodeComponent(item.location!);
                  final googleMapsUrl = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$query',
                  );

                  if (await canLaunchUrl(googleMapsUrl)) {
                    await launchUrl(
                      googleMapsUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              },
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

  Widget _buildHotelTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
  final List<String> pendingDocs;

  const FlightCard({
    super.key,
    required this.item,
    this.pendingDocs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final connections = item.connections ?? [];
    final hasConnections = connections.isNotEmpty;

    // Filter relevant docs for flight
    final relevantDocs = pendingDocs.where((doc) {
      final d = doc.toLowerCase();
      return d.contains('passaporte') ||
          d.contains('visto') ||
          d.contains('vacina') ||
          d.contains('menores');
    }).toList();

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (relevantDocs.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange.shade900.withValues(alpha: 0.2)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange.shade700.withValues(alpha: 0.5)
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pendente: ${relevantDocs.join(", ")}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Header: Icon + Airline/Flight Name
          Row(
            children: [
              Icon(
                Icons.flight_takeoff_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voo',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    item.name, // e.g., LATAM LA 3400
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              // NO PRICE TAG as requested
            ],
          ),

          const SizedBox(height: 24),

          // Route: Origin -> Destination with Times and Cities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Origin
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fromCode ?? 'ORG',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.startDateTime != null)
                    Text(
                      DateFormat('HH:mm').format(item.startDateTime!),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (item.fromCity != null)
                    Text(
                      'de ${item.fromCity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.6)
                            .withOpacity(0.7),
                      ),
                    ),
                ],
              ),

              // Center Graphic
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      if (item.durationString != null)
                        Text(
                          _formatDuration(item.durationString!),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.flight_takeoff,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Destination
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.toCode ?? 'DES',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      String timeText = '';
                      if (item.endDateTime != null) {
                        timeText = DateFormat(
                          'HH:mm',
                        ).format(item.endDateTime!);
                      } else if (hasConnections) {
                        final lastConn = connections.last;
                        final destMap = lastConn['destination'] is Map
                            ? lastConn['destination']
                            : null;
                        timeText =
                            destMap?['time']?.toString() ??
                            lastConn['hora_chegada']?.toString() ??
                            '';
                      } else if (item.startDateTime != null &&
                          item.durationString != null) {
                        try {
                          final duration = _parseDuration(item.durationString!);
                          if (duration != null) {
                            timeText = DateFormat(
                              'HH:mm',
                            ).format(item.startDateTime!.add(duration));
                          }
                        } catch (_) {}
                      }

                      if (timeText.isNotEmpty) {
                        return Text(
                          timeText,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12),
                  if (item.toCity != null)
                    Text(
                      'para ${item.toCity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.6)
                            .withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Connections Dropdown
          if (hasConnections)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(
                  'Escalas (${connections.length})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: connections
                    .map((conn) => _buildConnectionItem(context, conn))
                    .toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Voo direto',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionItem(BuildContext context, Map<String, dynamic> conn) {
    // Parse fields handling both flat and nested structures
    final originMap = conn['origin'] is Map ? conn['origin'] : null;
    final destMap = conn['destination'] is Map ? conn['destination'] : null;

    final originCode =
        originMap?['code']?.toString() ?? conn['origem']?.toString() ?? '';
    final originTime =
        originMap?['time']?.toString() ?? conn['hora_saida']?.toString() ?? '';

    final destCode =
        destMap?['code']?.toString() ?? conn['destino']?.toString() ?? '';
    final destTime =
        destMap?['time']?.toString() ?? conn['hora_chegada']?.toString() ?? '';

    final flightDuration =
        conn['duration']?.toString() ?? conn['duracao']?.toString() ?? '';
    final airlineName =
        conn['airline']?.toString() ??
        conn['companhia_codigo']?.toString() ??
        'Voo';
    final flightNum =
        conn['flightNumber']?.toString() ?? conn['voo']?.toString() ?? '';

    final layoverTime =
        conn['layoverDuration']?.toString() ??
        conn['tempo_conexao']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (layoverTime != null && layoverTime.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Tempo de conexão: $layoverTime',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Flight Name
              Row(
                children: [
                  Icon(Icons.flight, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$airlineName $flightNum',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Origin
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        originCode,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        originTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),

                  // Duration/Plane
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(flightDuration),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(
                                  Icons.flight_takeoff,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dest
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        destCode,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        destTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Duration? _parseDuration(String dStr) {
    if (dStr.isEmpty) return null;
    try {
      // 1. "HH:MM" format
      if (dStr.contains(':')) {
        final parts = dStr.split(':');
        if (parts.length >= 2) {
          return Duration(
            hours: int.tryParse(parts[0]) ?? 0,
            minutes: int.tryParse(parts[1]) ?? 0,
          );
        }
      }

      // 2. "1h 40min" or similar format
      if (dStr.toLowerCase().contains('h')) {
        final regex = RegExp(r'(\d+)h\s*(\d*)');
        final match = regex.firstMatch(dStr.toLowerCase());
        if (match != null) {
          final h = int.parse(match.group(1)!);
          final m = int.tryParse(match.group(2) ?? '0') ?? 0;
          return Duration(hours: h, minutes: m);
        }
      }

      // 3. Plain minutes "90"
      final numberRegex = RegExp(r'(\d+)');
      final match = numberRegex.firstMatch(dStr);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        return Duration(minutes: minutes);
      }
    } catch (_) {}
    return null;
  }

  String _formatDuration(String duration) {
    final d = _parseDuration(duration);
    if (d == null) return duration;

    final hours = d.inHours;
    final mins = d.inMinutes % 60;

    if (hours > 0) {
      if (mins > 0) {
        return '${hours}h ${mins}min';
      }
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }
}

class TransferCard extends StatelessWidget {
  final ItineraryItemEntity item;
  final bool showNextDayTag;

  const TransferCard({
    super.key,
    required this.item,
    this.showNextDayTag = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.type == ItineraryType.returnType
                ? Icons.keyboard_return
                : Icons.directions_bus_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.startDateTime != null)
                      Text(
                        DateFormat('HH:mm').format(item.startDateTime!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    if (showNextDayTag) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          'Dia seguinte ao voo',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TravelTimeWidget extends StatelessWidget {
  final String? duration;
  const TravelTimeWidget({super.key, this.duration});

  @override
  Widget build(BuildContext context) {
    final bool hasDuration = duration != null && duration!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 45,
          ), // Espaço para alinhar após a linha tracejada (30px da linha - 20px padding + offset)
          Expanded(
            child: Text(
              hasDuration
                  ? 'Tempo de viagem: $duration'
                  : 'Não foi possível calcular o tempo de deslocamento',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: hasDuration
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
