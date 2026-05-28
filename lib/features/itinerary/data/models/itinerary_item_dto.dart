import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/itinerary_item.dart';

part 'itinerary_item_dto.freezed.dart';
part 'itinerary_item_dto.g.dart';

@freezed
abstract class ItineraryItemDto with _$ItineraryItemDto {
  const factory ItineraryItemDto({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'titulo') String? title,
    @JsonKey(name: 'nome') String? oldName,
    @JsonKey(name: 'subtitulo') String? subtitle,
    @JsonKey(name: 'tipo') required String typeString,
    @JsonKey(name: 'data') String? dateString,
    @JsonKey(name: 'hora_inicio') String? timeString,
    @JsonKey(name: 'hora_fim') String? endTimeString,
    @JsonKey(name: 'hora_inicio2') DateTime? startDateTimeOld,
    @JsonKey(name: 'descricao') String? description,
    @JsonKey(name: 'localizacao') String? location,
    @JsonKey(name: 'imagem') String? imageUrl,
    // Flight route codes
    @JsonKey(name: 'codigo_de') String? fromCode,
    @JsonKey(name: 'codigo_para') String? toCode,
    @JsonKey(name: 'de') String? fromCity,
    @JsonKey(name: 'para') String? toCity,
    @JsonKey(name: 'hora_de') String? fromTime,
    @JsonKey(name: 'hora_para') String? toTime,
    @JsonKey(name: 'atrasado') bool? isDelayed,
    @JsonKey(name: 'atraso') String? delay,
    // Transfer
    @JsonKey(name: 'motorista') String? driverName,
    @JsonKey(name: 'duracao') String? durationString,
    @JsonKey(name: 'tempo_deslocamento') String? travelTime,
    @JsonKey(name: 'conexoes') List<Map<String, dynamic>>? connections,
    @JsonKey(name: 'escalas') List<Map<String, dynamic>>? escalas,
    // Enriched location
    @JsonKey(name: 'endereco') String? address,
    @JsonKey(name: 'cidade') String? city,
    @JsonKey(name: 'estado') String? state,
    @JsonKey(name: 'pais') String? country,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'rating') double? rating,
    @JsonKey(name: 'estrelas') double? estrelas,
    @JsonKey(name: 'telefone') String? telefone,
    @JsonKey(name: 'website') String? website,
    @JsonKey(name: 'imagens') List<String>? images,
    @JsonKey(name: 'link_maps') String? linkMaps,
    @JsonKey(name: 'evento_referencia_id') String? eventoReferenciaId,
    @JsonKey(name: 'is_day_after_transfer') bool? isDayAfterTransfer,
    @JsonKey(name: 'dados') Map<String, dynamic>? dados,
    // Booking
    @JsonKey(name: 'preco') String? price,
    @JsonKey(name: 'site_url') String? siteUrl,
    @JsonKey(name: 'status') String? bookingStatus,
    // Transfer pickup time (separate from event start)
    @JsonKey(name: 'transfer_data') String? transferDate,
    @JsonKey(name: 'transfer_hora') String? transferHora,
    // Attachments (per-event docs/links)
    @JsonKey(name: 'attachments') List<Map<String, dynamic>>? attachments,
    // Per-passenger filter
    @JsonKey(name: 'passageiros') List<dynamic>? passageiros,
    // Google Places ID
    @JsonKey(name: 'place_id') String? placeId,
  }) = _ItineraryItemDto;

  const ItineraryItemDto._();

  factory ItineraryItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemDtoFromJson(json);

  ItineraryItemEntity toEntity() {
    ItineraryType type;
    switch (typeString.toUpperCase()) {
      case 'RESTAURANTE':
      case 'FOOD':
      case 'MEAL':
        type = ItineraryType.food;
        break;
      case 'HOTEL':
        if (subtitle != null && (subtitle!.toUpperCase() == 'CHECK-IN' || subtitle!.toUpperCase() == 'CHECKIN')) {
          type = ItineraryType.checkin;
        } else if (subtitle != null && (subtitle!.toUpperCase() == 'CHECK-OUT' || subtitle!.toUpperCase() == 'CHECKOUT')) {
          type = ItineraryType.checkout;
        } else {
          type = ItineraryType.hotel;
        }
        break;
      case 'CHECKIN':
      case 'CHECK_IN':
      case 'CHECK-IN':
        type = ItineraryType.checkin;
        break;
      case 'CHECKOUT':
      case 'CHECK_OUT':
      case 'CHECK-OUT':
        type = ItineraryType.checkout;
        break;
      case 'VISITA_TECNICA':
      case 'VISIT':
        type = ItineraryType.visit;
        break;
      case 'TEMPO_LIVRE':
      case 'LEISURE':
        type = ItineraryType.leisure;
        break;
      case 'DISEMBARK':
        type = ItineraryType.disembark;
        break;
      case 'CONNECTION':
        type = ItineraryType.connection;
        break;
      case 'AI_RECOMMENDATION':
        type = ItineraryType.aiRecommendation;
        break;
      case 'RETURN':
        type = ItineraryType.returnType;
        break;
      case 'TRANSPORTE':
      case 'TRANSFER':
        if (fromCode != null && fromCode!.isNotEmpty) {
          type = ItineraryType.flight;
        } else {
          type = ItineraryType.transfer;
        }
        break;
      case 'FLIGHT':
        type = ItineraryType.flight;
        break;
      case 'EVENTO':
      default:
        // BUG-011: removed unreachable FLIGHT/RETURN checks — they have explicit cases above.
        type = ItineraryType.other;
    }

    DateTime? start;
    DateTime? end;

    if (dateString != null) {
      final datePart = DateTime.parse(dateString!);

      if (timeString != null) {
        try {
          final timeParts = timeString!.split(':').map(int.parse).toList();
          start = DateTime(
            datePart.year,
            datePart.month,
            datePart.day,
            timeParts[0],
            timeParts[1],
            timeParts.length > 2 ? timeParts[2] : 0,
          );
        } catch (_) {}
      }

      if (endTimeString != null) {
        try {
          final endParts = endTimeString!.split(':').map(int.parse).toList();
          DateTime tempEnd = DateTime(
            datePart.year,
            datePart.month,
            datePart.day,
            endParts[0],
            endParts[1],
            endParts.length > 2 ? endParts[2] : 0,
          );

          if (start != null && tempEnd.isBefore(start)) {
            tempEnd = tempEnd.add(const Duration(days: 1));
          }
          end = tempEnd;
        } catch (_) {}
      }
    }

    if (start == null) {
      start = startDateTimeOld;
    }

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
      endDateTime: end,
      description: description,
      location: location,
      imageUrl: imageUrl,
      subtitle: subtitle,
      fromCode: fromCode,
      toCode: toCode,
      fromCity: fromCity,
      toCity: toCity,
      fromTime: fromTime,
      toTime: toTime,
      isDelayed: isDelayed,
      delay: delay,
      driverName: driverName,
      durationString: durationString,
      travelTime: travelTime,
      connections: connections ?? escalas,
      address: address,
      city: city,
      state: state,
      country: country,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      estrelas: estrelas,
      telefone: telefone,
      website: website,
      images: images,
      linkMaps: linkMaps,
      transportMode: dados?['transportMode'] as String?,
      eventoReferenciaId: eventoReferenciaId,
      isDayAfterTransfer: isDayAfterTransfer,
      transferDate: transferDate,
      transferTime: transferHora,
      price: price,
      siteUrl: siteUrl,
      bookingStatus: bookingStatus,
      amenities: (dados?['amenities'] as List?)?.cast<String>(),
      hotelDescription: dados?['description'] as String?,
      planeType: dados?['planeType'] as String?,
      attachments: attachments,
      placeId: placeId,
    );
  }
}
