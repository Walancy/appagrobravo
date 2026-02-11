import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';

part 'documents_state.freezed.dart';

@freezed
class DocumentsState with _$DocumentsState {
  const factory DocumentsState.initial() = _Initial;
  const factory DocumentsState.loading() = _Loading;
  const factory DocumentsState.loaded(List<DocumentEntity> documents) = _Loaded;
  const factory DocumentsState.error(String message) = _Error;
}

extension DocumentsStateX on DocumentsState {
  bool get hasPendingAction {
    return maybeWhen(
      loaded: (documents) {
        final mandatoryTypes = [
          DocumentType.passaporte,
          DocumentType.visto,
          DocumentType.vacina,
          DocumentType.seguro,
        ];

        for (final type in mandatoryTypes) {
          final doc = documents.cast<DocumentEntity?>().firstWhere(
            (d) => d?.type == type,
            orElse: () => null,
          );

          if (doc == null) return true;
          if (doc.status == DocumentStatus.recusado ||
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
