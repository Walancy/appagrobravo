// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  nome: json['nome'] as String,
  foto: json['foto'] as String?,
  roles: (json['tipouser'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nome': instance.nome,
      'foto': instance.foto,
      'tipouser': instance.roles,
    };
