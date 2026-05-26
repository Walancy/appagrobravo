import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_item.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// GenericEventCard — hotel, visit, food, meal, leisure, checkin, checkout, etc.
// ---------------------------------------------------------------------------

class GenericEventCard extends StatelessWidget {
  final ItineraryItemEntity item;
  const GenericEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHotel = item.type == ItineraryType.hotel ||
        item.type == ItineraryType.checkin ||
        item.type == ItineraryType.checkout;

    // Check-in / check-out badge
    String? hotelTag;
    Color hotelTagColor = Colors.blue;
    if (isHotel) {
      final sub = item.subtitle?.toLowerCase() ?? '';
      final nm = item.name.toLowerCase();
      if (sub.contains('check-in') ||
          nm.contains('check-in') ||
          item.type == ItineraryType.checkin) {
        hotelTag = 'CHECK-IN';
        hotelTagColor = Colors.blue;
      } else if (sub.contains('check-out') ||
          nm.contains('check-out') ||
          item.type == ItineraryType.checkout) {
        hotelTag = 'CHECK-OUT';
        hotelTagColor = Colors.orange;
      }
    }

    final firstImage = (item.images != null && item.images!.isNotEmpty)
        ? item.images!.first
        : item.imageUrl;

    final locationLabel = _buildLocationLabel();

    // Time range: "10:00" or "10:00 – 12:00" (only when times differ)
    String? timeLabel;
    if (item.startDateTime != null) {
      final s = DateFormat('HH:mm').format(item.startDateTime!);
      if (item.endDateTime != null) {
        final e = DateFormat('HH:mm').format(item.endDateTime!);
        timeLabel = (e != s) ? '$s – $e' : s;
      } else {
        timeLabel = s;
      }
    }

    final bookingBadge = _buildBookingBadge();

    // Show subtitle only when it's distinct from the name and not the hotel tag
    final showSubtitle = item.subtitle != null &&
        item.subtitle!.isNotEmpty &&
        item.subtitle!.toLowerCase() != item.name.toLowerCase() &&
        hotelTag == null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstImage != null)
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.network(
                firstImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                          if (showSubtitle)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.subtitle!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          if (isHotel && item.estrelas != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _buildStars(item.estrelas!),
                            ),
                          if (locationLabel != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    locationLabel,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.rating != null && item.rating! > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 2),
                                  Text(
                                    item.rating!.toStringAsFixed(1),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Right column: time range + tags
                    if (timeLabel != null ||
                        hotelTag != null ||
                        bookingBadge != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (timeLabel != null)
                            Text(
                              timeLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          if (hotelTag != null) ...[
                            if (timeLabel != null) const SizedBox(height: 4),
                            _buildTag(hotelTag, hotelTagColor),
                          ],
                          if (bookingBadge != null) ...[
                            const SizedBox(height: 4),
                            bookingBadge,
                          ],
                        ],
                      ),
                  ],
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _buildLocationLabel() {
    final parts = <String>[];
    // Prefer specific address over generic location string
    if (item.address != null && item.address!.isNotEmpty) {
      parts.add(item.address!);
    } else if (item.location != null && item.location!.isNotEmpty) {
      parts.add(item.location!);
    }
    if (item.city != null && item.city!.isNotEmpty) {
      if (!parts.any((p) => p.contains(item.city!))) parts.add(item.city!);
    }
    if (item.country != null &&
        item.country!.isNotEmpty &&
        item.country != item.city) {
      parts.add(item.country!);
    }
    return parts.isEmpty ? null : parts.join(', ');
  }

  Widget? _buildBookingBadge() {
    if (item.bookingStatus == null || item.bookingStatus!.isEmpty) return null;
    Color color;
    String label;
    switch (item.bookingStatus!.toLowerCase()) {
      case 'confirmed':
        return null;
      case 'quoting':
        color = Colors.orange;
        label = 'Cotando';
        break;
      case 'quoted':
        color = Colors.blue;
        label = 'Cotado';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pendente';
        break;
      default:
        return null;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final hasWebsite = (item.website != null && item.website!.isNotEmpty) ||
        (item.siteUrl != null && item.siteUrl!.isNotEmpty);
    final hasMaps = item.location != null ||
        item.address != null ||
        item.linkMaps != null ||
        (item.latitude != null && item.longitude != null);

    if (!hasMaps && !hasWebsite) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasMaps)
          _actionButton(
            context,
            icon: Icons.location_on_outlined,
            label: 'Ver no Mapa',
            onTap: _launchMaps,
          ),
        if (hasWebsite)
          _actionButton(
            context,
            icon: Icons.language_outlined,
            label: 'Site',
            onTap: _launchWebsite,
          ),
      ],
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.06),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          textStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps() async {
    Uri? uri;
    // INC-018: place_id deeplink is most reliable (opens correct venue with reviews)
    if (item.placeId != null && item.placeId!.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/place/?q=place_id:${item.placeId}',
      );
    } else if (item.linkMaps != null && item.linkMaps!.isNotEmpty) {
      uri = Uri.tryParse(item.linkMaps!);
    } else if (item.latitude != null && item.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${item.latitude},${item.longitude}',
      );
    } else {
      final query = item.address ?? item.location ?? '';
      if (query.isNotEmpty) {
        uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
        );
      }
    }
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWebsite() async {
    final url =
        item.website?.isNotEmpty == true ? item.website : item.siteUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStars(double count) {
    final full = count.floor();
    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star_rounded,
              size: 14, color: Color(0xFFF59E0B));
        }
        return Icon(Icons.star_outline_rounded,
            size: 14,
            color: const Color(0xFFF59E0B).withOpacity(0.4));
      }),
    );
  }

  IconData _getIconForType(ItineraryType type) {
    switch (type) {
      case ItineraryType.food:
      case ItineraryType.meal:
        return Icons.restaurant_outlined;
      case ItineraryType.hotel:
      case ItineraryType.checkin:
      case ItineraryType.checkout:
        return Icons.hotel_outlined;
      case ItineraryType.visit:
        return Icons.business_outlined;
      case ItineraryType.leisure:
        return Icons.local_activity_outlined;
      case ItineraryType.returnType:
        return Icons.keyboard_return;
      case ItineraryType.aiRecommendation:
        return Icons.auto_awesome_outlined;
      default:
        return Icons.event_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// FlightCard — voos e conexões
// ---------------------------------------------------------------------------

class FlightCard extends StatelessWidget {
  final ItineraryItemEntity item;

  const FlightCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final connections = item.connections ?? [];
    final hasConnections = connections.isNotEmpty;
    final isDelayed = item.isDelayed == true;

    final fromTimeLabel = item.fromTime?.isNotEmpty == true
        ? item.fromTime!
        : (item.startDateTime != null
            ? DateFormat('HH:mm').format(item.startDateTime!)
            : null);

    final toTimeLabel = item.toTime?.isNotEmpty == true
        ? item.toTime!
        : _resolveArrivalTime(hasConnections, connections);

    // Airline/flight number info from subtitle (e.g. "GOL 1234" or "LATAM LA3456")
    final subtitle = item.subtitle?.trim();
    final airlineInfo = (subtitle != null && 
                         subtitle.isNotEmpty && 
                         subtitle.toLowerCase() != 'voo' &&
                         subtitle.toLowerCase() != item.name.toLowerCase())
        ? subtitle
        : null;

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF2F4F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDelayed
              ? Colors.orange.withOpacity(0.4)
              : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
        child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.flight_takeoff_outlined,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voo',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      item.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (airlineInfo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          airlineInfo,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isDelayed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        item.delay?.isNotEmpty == true
                            ? 'ATRASADO ${item.delay}'
                            : 'ATRASADO',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Route
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
                  if (fromTimeLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      fromTimeLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (item.fromCity != null)
                    Text(
                      'de ${item.fromCity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),

              // Center
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.flight_takeoff,
                                color: AppColors.primary, size: 16),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      if (hasConnections)
                        Text(
                          '${connections.length} escala${connections.length > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
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
                  if (toTimeLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      toTimeLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (item.toCity != null)
                    Text(
                      'para ${item.toCity}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Connections / escalas
          if (hasConnections)
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(
                  'Escalas (${connections.length})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  String? _resolveArrivalTime(
      bool hasConnections, List<Map<String, dynamic>> connections) {
    if (item.endDateTime != null) {
      return DateFormat('HH:mm').format(item.endDateTime!);
    }
    if (hasConnections) {
      final lastConn = connections.last;
      final destMap =
          lastConn['destination'] is Map ? lastConn['destination'] : null;
      final t = destMap?['time']?.toString() ??
          lastConn['hora_chegada']?.toString();
      if (t != null && t.isNotEmpty) return t;
    }
    if (item.startDateTime != null && item.durationString != null) {
      try {
        final d = _parseDuration(item.durationString!);
        if (d != null) {
          return DateFormat('HH:mm').format(item.startDateTime!.add(d));
        }
      } catch (_) {}
    }
    return null;
  }

  Widget _buildConnectionItem(
      BuildContext context, Map<String, dynamic> conn) {
    final originMap = conn['origin'] is Map ? conn['origin'] : null;
    final destMap = conn['destination'] is Map ? conn['destination'] : null;

    final originCode =
        originMap?['code']?.toString() ?? conn['origem']?.toString() ?? '';
    final originTime =
        originMap?['time']?.toString() ?? conn['hora_saida']?.toString() ?? '';
    final destCode =
        destMap?['code']?.toString() ?? conn['destino']?.toString() ?? '';
    final destTime = destMap?['time']?.toString() ??
        conn['hora_chegada']?.toString() ?? '';
    final flightDuration =
        conn['duration']?.toString() ?? conn['duracao']?.toString() ?? '';
    final airlineName = conn['airline']?.toString() ??
        conn['companhia_codigo']?.toString() ??
        'Voo';
    final flightNum =
        conn['flightNumber']?.toString() ?? conn['voo']?.toString() ?? '';
    final layoverTime = conn['layoverDuration']?.toString() ??
        conn['tempo_conexao']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (layoverTime != null && layoverTime.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  'Tempo de conexão: $layoverTime',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
                color:
                    Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(originCode,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        originTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            _formatDuration(flightDuration),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.flight_takeoff,
                                    size: 14, color: AppColors.primary),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(destCode,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        destTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
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
      if (dStr.contains(':')) {
        final parts = dStr.split(':');
        if (parts.length >= 2) {
          return Duration(
            hours: int.tryParse(parts[0]) ?? 0,
            minutes: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      if (dStr.toLowerCase().contains('h')) {
        final regex = RegExp(r'(\d+)h\s*(\d*)');
        final match = regex.firstMatch(dStr.toLowerCase());
        if (match != null) {
          return Duration(
            hours: int.parse(match.group(1)!),
            minutes: int.tryParse(match.group(2) ?? '0') ?? 0,
          );
        }
      }
      final match = RegExp(r'(\d+)').firstMatch(dStr);
      if (match != null) return Duration(minutes: int.parse(match.group(1)!));
    } catch (_) {}
    return null;
  }

  String _formatDuration(String duration) {
    final d = _parseDuration(duration);
    if (d == null) return duration;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}min' : '${h}h';
    return '${m}min';
  }
}

// ---------------------------------------------------------------------------
// TransferCard — transfers, desembarques, retornos
// ---------------------------------------------------------------------------

class TransferCard extends StatelessWidget {
  final ItineraryItemEntity item;
  final bool showNextDayTag;
  final String? distancia;

  const TransferCard({
    super.key,
    required this.item,
    this.showNextDayTag = false,
    this.distancia,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duration = item.travelTime?.isNotEmpty == true
        ? item.travelTime
        : item.durationString;
    // Disembark is an arrival event — don't show its own duration chip
    final hasDuration = duration != null &&
        duration.isNotEmpty &&
        item.type != ItineraryType.disembark;

    final hasRoute =
        (item.fromCity != null && item.fromCity!.isNotEmpty) ||
            (item.toCity != null && item.toCity!.isNotEmpty);

    final mutedColor = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.45);
    final chipColor =
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF3B82F6);
    final chipBg =
        isDark ? const Color(0xFF1D4ED8).withValues(alpha: 0.2) : const Color(0xFFEFF6FF);

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBFDBFE), Color(0xFF6EE7B7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main row
            Row(
              children: [
                Icon(
                  _transportIcon(),
                  size: 16,
                  color: isDark
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF60A5FA),
                ),
                const SizedBox(width: 6),
                if (item.startDateTime != null || item.endDateTime != null) ...[
                  Text(
                    DateFormat('HH:mm').format(
                        item.startDateTime ?? item.endDateTime!),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '·',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasDuration) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 10, color: chipColor),
                        const SizedBox(width: 3),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: chipColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (distancia != null && distancia!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.route_outlined,
                            size: 10, color: chipColor),
                        const SizedBox(width: 3),
                        Text(
                          distancia!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: chipColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (showNextDayTag) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      'Dia seguinte',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // From → To row
            if (hasRoute) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 22),
                  Icon(Icons.arrow_forward,
                      size: 11, color: mutedColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _routeLabel(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: mutedColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _routeLabel() {
    final from = item.fromCity;
    final to = item.toCity;
    if (from != null && to != null) return '$from → $to';
    if (from != null) return 'de $from';
    if (to != null) return 'para $to';
    return '';
  }

  IconData _transportIcon() {
    switch (item.type) {
      case ItineraryType.returnType:
        return Icons.keyboard_return;
      case ItineraryType.disembark:
        return Icons.flight_land_outlined;
      default:
        switch (item.transportMode) {
          case 'walking':
            return Icons.directions_walk_outlined;
          case 'bicycling':
            return Icons.directions_bike_outlined;
          case 'transit':
            return Icons.train_outlined;
          default:
            return Icons.directions_bus_outlined;
        }
    }
  }
}

// ---------------------------------------------------------------------------
// TravelTimeWidget — tempo entre dois eventos consecutivos sem transfer
// ---------------------------------------------------------------------------

class TravelTimeWidget extends StatelessWidget {
  final String? duration;
  const TravelTimeWidget({super.key, this.duration});

  @override
  Widget build(BuildContext context) {
    if (duration == null || duration!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 45),
          Icon(
            Icons.directions_walk_outlined,
            size: 13,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 6),
          Text(
            'Tempo de deslocamento: $duration',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
