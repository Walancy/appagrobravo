import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String nome,
    String? foto,
    @JsonKey(name: 'tipouser') required List<String> roles,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: nome,
    avatarUrl: foto,
    roles: roles,
  );
}
