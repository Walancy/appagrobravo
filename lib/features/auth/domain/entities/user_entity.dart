import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String name,
    required List<String> roles, // Mapped from 'tipouser'
  }) = _UserEntity;

  const UserEntity._();

  bool get isGuide =>
      roles.contains('GUIA') ||
      roles.contains('COLABORADOR') ||
      roles.contains('MASTER');
  bool get isUserApp => roles.contains('USER_APP');
}
