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
    DateTime? endDate,
    String? groupName,
    String? groupLogo,
    int? pendingDocsCount,
    @Default(false) bool passaporteObrigatorio,
    @Default(false) bool vistoObrigatorio,
    @Default(false) bool vacinaObrigatoria,
    @Default(false) bool seguroObrigatorio,
    @Default(false) bool carteiraObrigatoria,
    @Default(false) bool autorizacaoObrigatoria,
  }) = _MissionEntity;

  const MissionEntity._();
}
