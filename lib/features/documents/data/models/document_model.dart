import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

@freezed
abstract class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String? tipo,
    required String? status,
    @JsonKey(name: 'foto_doc') required String? fotoDoc,
    @JsonKey(name: 'nome_documento') required String? nomeDocumento,
    @JsonKey(name: 'numero_documento') required String? numeroDocumento,
    @JsonKey(name: 'validade_doc') required String? validadeDoc,
    @JsonKey(name: 'data_envio') required String? dataEnvio,
    @JsonKey(name: 'motivoRecusa') required String? motivoRecusa,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  const DocumentModel._();

  DocumentEntity toEntity() {
    return DocumentEntity(
      id: id,
      type: DocumentType.fromString(tipo),
      status: DocumentStatus.fromString(status),
      imageUrl: fotoDoc,
      title: nomeDocumento ?? DocumentType.fromString(tipo).label,
      documentNumber: numeroDocumento,
      expiryDate: validadeDoc != null ? DateTime.tryParse(validadeDoc!) : null,
      uploadDate: dataEnvio != null ? DateTime.tryParse(dataEnvio!) : null,
      rejectionReason: motivoRecusa,
    );
  }
}
