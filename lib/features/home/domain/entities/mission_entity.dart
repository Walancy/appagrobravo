import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_entity.freezed.dart';

@freezed
abstract class MissionEntity with _$MissionEntity {
  const factory MissionEntity({
    required String id,
    required String name,
    String? logo,
  }) = _MissionEntity;

  const MissionEntity._();
}
