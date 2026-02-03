import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/itinerary_item.dart';

part 'itinerary_item_dto.freezed.dart';
part 'itinerary_item_dto.g.dart';

@freezed
abstract class ItineraryItemDto with _$ItineraryItemDto {
  const factory ItineraryItemDto({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'titulo') String? title, // Mapped from 'titulo'
    @JsonKey(name: 'nome') String? oldName, // Backwards compat
    @JsonKey(name: 'tipo') required String typeString,
    @JsonKey(name: 'data') String? dateString,
    @JsonKey(name: 'hora_inicio') String? timeString,
    @JsonKey(name: 'hora_fim') String? endTimeString,
    @JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,
    @JsonKey(name: 'descricao') String? description,
    @JsonKey(name: 'localizacao') String? location,
    @JsonKey(name: 'imagem') String? imageUrl,
    @JsonKey(name: 'codigo_de') String? fromCode,
    @JsonKey(name: 'codigo_para') String? toCode,
    @JsonKey(name: 'de') String? fromCity,
    @JsonKey(name: 'para') String? toCity,
    @JsonKey(name: 'motorista') String? driverName,
    @JsonKey(name: 'duracao') String? durationString,
  }) = _ItineraryItemDto;

  const ItineraryItemDto._();

  factory ItineraryItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemDtoFromJson(json);

  ItineraryItemEntity toEntity() {
    ItineraryType type;
    switch (typeString.toUpperCase()) {
      // Standardize case
      case 'RESTAURANTE':
      case 'FOOD':
        type = ItineraryType.food;
        break;
      case 'HOTEL':
        type = ItineraryType.hotel;
        break;
      case 'VISITA_TECNICA':
      case 'VISIT':
        type = ItineraryType.visit;
        break;
      case 'TEMPO_LIVRE':
      case 'LEISURE':
        type = ItineraryType.leisure;
        break;
      case 'TRANSPORTE':
      case 'TRANSFER':
      case 'FLIGHT': // Flight is distinct in enum but 'tipo' in DB might differ
        if (fromCode != null && fromCode!.isNotEmpty) {
          type = ItineraryType.flight;
        } else if (typeString.toUpperCase() == 'FLIGHT') {
          type = ItineraryType.flight;
        } else {
          type = ItineraryType.transfer;
        }
        break;

      // Handle legacy/other cases
      case 'EVENTO':
      default:
        if (typeString.toUpperCase() == 'FLIGHT') {
          type = ItineraryType.flight;
        } else if (typeString.toUpperCase() == 'RETURN') {
          // Case seen in DB
          type = ItineraryType.transfer; // Return often implies transfer
        } else {
          type = ItineraryType.other;
        }
    }

    // Date Logic
    DateTime? start;
    if (dateString != null && timeString != null) {
      try {
        // Parse "YYYY-MM-DD" and "HH:MM:SS"
        final datePart = DateTime.parse(dateString!);
        final timeParts = timeString!.split(':').map(int.parse).toList();
        start = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timeParts[0],
          timeParts[1],
          timeParts.length > 2 ? timeParts[2] : 0,
        );
      } catch (_) {
        start = startDateTimeOld;
      }
    } else {
      start = startDateTimeOld;
    }

    // Fallback if data is only in one place and not the other, try to parse what we have.
    if (start == null && dateString != null) {
      try {
        start = DateTime.parse(dateString!);
      } catch (_) {}
    }

    return ItineraryItemEntity(
      id: id,
      name: title ?? oldName ?? 'Evento sem nome',
      type: type,
      startDateTime: start,
      endDateTime: null, // Logic for end time could be similar if needed
      description: description,
      location: location,
      imageUrl: imageUrl,
      fromCode: fromCode,
      toCode: toCode,
      fromCity: fromCity,
      toCity: toCity,
      driverName: driverName,
      durationString: durationString,
    );
  }
}
