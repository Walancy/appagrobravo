import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_entity.freezed.dart';

enum ConnectionStatus { none, pendingSent, pendingReceived, connected }

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required String id,
    required String name,
    required String? avatarUrl,
    required String? coverUrl,
    required String? jobTitle,
    required String? company,
    required String? bio,
    required String? missionName,
    required String? groupName,
    required String? email,
    required String? phone,
    required String? cpf,
    required String? ssn,
    required String? zipCode,
    required String? state,
    required String? city,
    required String? street,
    required String? number,
    required String? neighborhood,
    required String? complement,
    required DateTime? birthDate,
    required String? nationality,
    required String? passport,
    required List<String>? foodPreferences,
    required List<String>? medicalRestrictions,
    required int connectionsCount,
    required int postsCount,
    required int missionsCount,
    @Default(ConnectionStatus.none) ConnectionStatus connectionStatus,
  }) = _ProfileEntity;

  const ProfileEntity._();
}
