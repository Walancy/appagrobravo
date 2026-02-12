import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_entity.freezed.dart';

@freezed
abstract class MissionEntity with _$MissionEntity {
  const factory MissionEntity({
    required String id,
    required String name,
    String? logo,
    String? location,
    DateTime? startDate,
    String? groupName,
    String? groupLogo,
    int? pendingDocsCount,
  }) = _MissionEntity;

  const MissionEntity._();
}
