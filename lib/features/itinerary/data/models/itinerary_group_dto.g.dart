// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItineraryGroupDto _$ItineraryGroupDtoFromJson(Map<String, dynamic> json) =>
    _ItineraryGroupDto(
      id: json['id'] as String,
      name: json['nome'] as String,
      startDate: DateTime.parse(json['data_inicio'] as String),
      endDate: DateTime.parse(json['data_fim'] as String),
    );

Map<String, dynamic> _$ItineraryGroupDtoToJson(_ItineraryGroupDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.name,
      'data_inicio': instance.startDate.toIso8601String(),
      'data_fim': instance.endDate.toIso8601String(),
    };
