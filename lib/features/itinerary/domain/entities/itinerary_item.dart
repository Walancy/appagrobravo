import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_item.freezed.dart';

enum ItineraryType {
  flight,
  visit,
  hotel,
  food,
  leisure,
  transfer,
  returnType,
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
    // Flight specific
    String? fromCode,
    String? toCode,
    String? fromCity,
    String? toCity,
    // Transfer specific
    String? driverName,
    String? durationString,
    String? travelTime,
    List<Map<String, dynamic>>? connections,
  }) = _ItineraryItemEntity;

  const ItineraryItemEntity._();
}
