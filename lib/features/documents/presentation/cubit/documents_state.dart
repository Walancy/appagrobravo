import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../home/domain/entities/mission_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/document_enums.dart';

part 'documents_state.freezed.dart';

@freezed
class DocumentsState with _$DocumentsState {
  const factory DocumentsState.initial() = _Initial;
  const factory DocumentsState.loading() = _Loading;
  const factory DocumentsState.loaded(
    List<DocumentEntity> documents, {
    @Default(false) bool isAlertDismissed,
    ProfileEntity? profile,
    MissionEntity? mission,
  }) = _Loaded;
  const factory DocumentsState.error(String message) = _Error;
}

extension DocumentsStateX on DocumentsState {
  bool get hasPendingAction {
    return maybeWhen(
      loaded: (documents, isAlertDismissed, profile, mission) {
        if (isAlertDismissed) return false;

        // Calculate Age
        bool isUnder18 = false;
        if (profile?.birthDate != null) {
          final today = DateTime.now();
          final birthDate = profile!.birthDate!;
          int age = (today.year - birthDate.year).toInt();
          if (today.month < birthDate.month ||
              (today.month == birthDate.month && today.day < birthDate.day)) {
            age--;
          }
          isUnder18 = age < 18;
        }

        final List<DocumentType> mandatoryTypes;

        if (mission != null) {
          mandatoryTypes = [
            if (mission.passaporteObrigatorio) DocumentType.passaporte,
            if (mission.vistoObrigatorio) DocumentType.visto,
            if (mission.vacinaObrigatoria) DocumentType.vacina,
            if (mission.seguroObrigatorio) DocumentType.seguro,
            if (mission.carteiraObrigatoria) DocumentType.carteiraMotorista,
            if (mission.autorizacaoObrigatoria && isUnder18)
              DocumentType.autorizacaoMenores,
          ];
        } else {
          // Fallback baseline
          mandatoryTypes = [
            DocumentType.passaporte,
            DocumentType.visto,
            DocumentType.vacina,
            DocumentType.seguro,
            if (isUnder18) DocumentType.autorizacaoMenores,
          ];
        }

        for (final type in mandatoryTypes) {
          final doc = documents.cast<DocumentEntity?>().firstWhere(
            (d) => d?.type == type,
            orElse: () => null,
          );

          if (doc == null) return true;
          if (doc.status == DocumentStatus.pendente ||
              doc.status == DocumentStatus.recusado ||
              doc.status == DocumentStatus.expirado) {
            return true;
          }
        }
        return false;
      },
      orElse: () => false,
    );
  }
}
