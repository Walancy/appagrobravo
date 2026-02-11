// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    _DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tipo: json['tipo'] as String?,
      status: json['status'] as String?,
      fotoDoc: json['foto_doc'] as String?,
      nomeDocumento: json['nome_documento'] as String?,
      numeroDocumento: json['numero_documento'] as String?,
      validadeDoc: json['validade_doc'] as String?,
      dataEnvio: json['data_envio'] as String?,
      motivoRecusa: json['motivoRecusa'] as String?,
    );

Map<String, dynamic> _$DocumentModelToJson(_DocumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'tipo': instance.tipo,
      'status': instance.status,
      'foto_doc': instance.fotoDoc,
      'nome_documento': instance.nomeDocumento,
      'numero_documento': instance.numeroDocumento,
      'validade_doc': instance.validadeDoc,
      'data_envio': instance.dataEnvio,
      'motivoRecusa': instance.motivoRecusa,
    };
