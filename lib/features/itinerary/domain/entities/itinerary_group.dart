import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_group.freezed.dart';

@freezed
abstract class ItineraryGroupEntity with _$ItineraryGroupEntity {
  const factory ItineraryGroupEntity({
    required String id,
    required String name,
    String? missionName,
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) = _ItineraryGroupEntity;

  const ItineraryGroupEntity._();
}
