// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItineraryItemDto _$ItineraryItemDtoFromJson(Map<String, dynamic> json) =>
    _ItineraryItemDto(
      id: json['id'] as String,
      title: json['titulo'] as String?,
      oldName: json['nome'] as String?,
      subtitle: json['subtitulo'] as String?,
      typeString: json['tipo'] as String,
      dateString: json['data'] as String?,
      timeString: json['hora_inicio'] as String?,
      endTimeString: json['hora_fim'] as String?,
      startDateTimeOld: json['hora_inicio2'] == null
          ? null
          : DateTime.parse(json['hora_inicio2'] as String),
      description: json['descricao'] as String?,
      location: json['localizacao'] as String?,
      imageUrl: json['imagem'] as String?,
      fromCode: json['codigo_de'] as String?,
      toCode: json['codigo_para'] as String?,
      fromCity: json['de'] as String?,
      toCity: json['para'] as String?,
      fromTime: json['hora_de'] as String?,
      toTime: json['hora_para'] as String?,
      isDelayed: json['atrasado'] as bool?,
      delay: json['atraso'] as String?,
      driverName: json['motorista'] as String?,
      durationString: json['duracao'] as String?,
      travelTime: json['tempo_deslocamento'] as String?,
      connections: (json['conexoes'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      escalas: (json['escalas'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      address: json['endereco'] as String?,
      city: json['cidade'] as String?,
      state: json['estado'] as String?,
      country: json['pais'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      estrelas: (json['estrelas'] as num?)?.toDouble(),
      telefone: json['telefone'] as String?,
      website: json['website'] as String?,
      images: (json['imagens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkMaps: json['link_maps'] as String?,
      eventoReferenciaId: json['evento_referencia_id'] as String?,
      isDayAfterTransfer: json['is_day_after_transfer'] as bool?,
      dados: json['dados'] as Map<String, dynamic>?,
      price: json['preco'] as String?,
      siteUrl: json['site_url'] as String?,
      bookingStatus: json['status'] as String?,
    );

Map<String, dynamic> _$ItineraryItemDtoToJson(_ItineraryItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.title,
      'nome': instance.oldName,
      'subtitulo': instance.subtitle,
      'tipo': instance.typeString,
      'data': instance.dateString,
      'hora_inicio': instance.timeString,
      'hora_fim': instance.endTimeString,
      'hora_inicio2': instance.startDateTimeOld?.toIso8601String(),
      'descricao': instance.description,
      'localizacao': instance.location,
      'imagem': instance.imageUrl,
      'codigo_de': instance.fromCode,
      'codigo_para': instance.toCode,
      'de': instance.fromCity,
      'para': instance.toCity,
      'hora_de': instance.fromTime,
      'hora_para': instance.toTime,
      'atrasado': instance.isDelayed,
      'atraso': instance.delay,
      'motorista': instance.driverName,
      'duracao': instance.durationString,
      'tempo_deslocamento': instance.travelTime,
      'conexoes': instance.connections,
      'escalas': instance.escalas,
      'endereco': instance.address,
      'cidade': instance.city,
      'estado': instance.state,
      'pais': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'estrelas': instance.estrelas,
      'telefone': instance.telefone,
      'website': instance.website,
      'imagens': instance.images,
      'link_maps': instance.linkMaps,
      'evento_referencia_id': instance.eventoReferenciaId,
      'is_day_after_transfer': instance.isDayAfterTransfer,
      'dados': instance.dados,
      'preco': instance.price,
      'site_url': instance.siteUrl,
      'status': instance.bookingStatus,
    };
