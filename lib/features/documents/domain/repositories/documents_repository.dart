import 'dart:io';
import 'package:agrobravo/features/documents/domain/entities/document_enums.dart';
import 'package:agrobravo/features/documents/domain/entities/document_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DocumentsRepository {
  Future<Either<Exception, List<DocumentEntity>>> getDocuments();
  Future<Either<Exception, void>> uploadDocument({
    required DocumentType type,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  });
}
