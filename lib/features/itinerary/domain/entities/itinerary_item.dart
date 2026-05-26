import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_item.freezed.dart';

enum ItineraryType {
  flight,
  visit,
  hotel,
  food,
  meal,
  leisure,
  transfer,
  returnType,
  checkin,
  checkout,
  disembark,
  connection,
  aiRecommendation,
  other,
}

@freezed
abstract class ItineraryItemEntity with _$ItineraryItemEntity {
  const factory ItineraryItemEntity({
    required String id,
    required String name,
    required ItineraryType type,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? description,
    String? location,
    String? imageUrl,
    // Subtitle label (check-in / check-out from panel)
    String? subtitle,
    // Flight specific
    String? fromCode,
    String? toCode,
    String? fromCity,
    String? toCity,
    String? fromTime,
    String? toTime,
    bool? isDelayed,
    String? delay,
    // Transfer specific
    String? driverName,
    String? durationString,
    String? travelTime,
    List<Map<String, dynamic>>? connections,
    // Enriched location (new DB columns from panel)
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    double? rating,
    double? estrelas,
    String? telefone,
    String? website,
    List<String>? images,
    String? linkMaps,
    // Transfer
    String? transportMode,
    String? eventoReferenciaId,
    bool? isDayAfterTransfer,
    String? transferDate,
    String? transferTime,
    // Booking info
    String? price,
    String? siteUrl,
    String? bookingStatus,
    // Hotel / venue extras (from dados JSONB)
    List<String>? amenities,
    String? hotelDescription,
    String? planeType,
    // Attachments (per-event documents/links from panel)
    List<Map<String, dynamic>>? attachments,
    // Google Places deep link
    String? placeId,
  }) = _ItineraryItemEntity;

  const ItineraryItemEntity._();
}
