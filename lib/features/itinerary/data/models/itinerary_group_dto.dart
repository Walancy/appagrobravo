import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/itinerary_group.dart';

part 'itinerary_group_dto.freezed.dart';
part 'itinerary_group_dto.g.dart';

@freezed
abstract class ItineraryGroupDto with _$ItineraryGroupDto {
  const factory ItineraryGroupDto({
    required String id,
    @JsonKey(name: 'nome') required String name,
    @JsonKey(name: 'data_inicio') required DateTime startDate,
    @JsonKey(name: 'data_fim') required DateTime endDate,
  }) = _ItineraryGroupDto;

  const ItineraryGroupDto._();

  factory ItineraryGroupDto.fromJson(Map<String, dynamic> json) =>
      _$ItineraryGroupDtoFromJson(json);

  ItineraryGroupEntity toEntity() {
    return ItineraryGroupEntity(
      id: id,
      name: name,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
