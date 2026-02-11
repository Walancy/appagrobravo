import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'document_entity.freezed.dart';

@freezed
abstract class DocumentEntity with _$DocumentEntity {
  const factory DocumentEntity({
    required String id,
    required DocumentType type,
    required DocumentStatus status,
    required String? imageUrl,
    required String? title,
    required String? documentNumber,
    required DateTime? expiryDate,
    required DateTime? uploadDate,
    required String? rejectionReason,
  }) = _DocumentEntity;
}
