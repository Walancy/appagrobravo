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
      driverName: json['motorista'] as String?,
      durationString: json['duracao'] as String?,
      travelTime: json['tempo_deslocamento'] as String?,
    );

Map<String, dynamic> _$ItineraryItemDtoToJson(_ItineraryItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.title,
      'nome': instance.oldName,
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
      'motorista': instance.driverName,
      'duracao': instance.durationString,
      'tempo_deslocamento': instance.travelTime,
    };
