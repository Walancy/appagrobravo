part of 'itinerary_cubit.dart';

@freezed
class ItineraryState with _$ItineraryState {
  const factory ItineraryState.initial() = _Initial;
  const factory ItineraryState.loading() = _Loading;
  const factory ItineraryState.loaded(
    ItineraryGroupEntity group,
    List<ItineraryItemEntity> items,
  ) = _Loaded;
  const factory ItineraryState.error(String message) = _Error;
}
