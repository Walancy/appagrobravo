import 'dart:io';
import 'package:agrobravo/features/documents/domain/entities/document_enums.dart';
import 'package:agrobravo/features/documents/domain/entities/document_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DocumentsRepository {
  Future<Either<Exception, List<DocumentEntity>>> getDocuments();
  Future<Either<Exception, void>> uploadDocument({
    String? id,
    required DocumentType type,
    File? file,
    String? documentNumber,
    DateTime? expiryDate,
    String? documentName,
    String? visaCountry,
  });
  Future<Either<Exception, Map<String, dynamic>>> parseDocument({
    required DocumentType type,
    required File file,
  });
}
