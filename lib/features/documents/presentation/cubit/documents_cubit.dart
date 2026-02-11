import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/document_enums.dart';
import '../../domain/repositories/documents_repository.dart';
import 'documents_state.dart';

@injectable
class DocumentsCubit extends Cubit<DocumentsState> {
  final DocumentsRepository _repository;

  DocumentsCubit(this._repository) : super(const DocumentsState.initial());

  Future<void> loadDocuments() async {
    emit(const DocumentsState.loading());
    final result = await _repository.getDocuments();

    result.fold(
      (error) => emit(DocumentsState.error(error.toString())),
      (documents) => emit(DocumentsState.loaded(documents)),
    );
  }

  Future<void> uploadDocument({
    required DocumentType type,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    // We don't emit loading here because we want to keep the current list visible
    // if possible, or we can handle a separate "uploading" state.
    // For simplicity, let's just trigger loadDocuments after success.

    final result = await _repository.uploadDocument(
      type: type,
      file: file,
      documentNumber: documentNumber,
      expiryDate: expiryDate,
    );

    result.fold(
      (error) => emit(DocumentsState.error(error.toString())),
      (_) => loadDocuments(),
    );
  }
}
