import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';
import '../../domain/repositories/documents_repository.dart';
import '../models/document_model.dart';

@LazySingleton(as: DocumentsRepository)
class DocumentsRepositoryImpl implements DocumentsRepository {
  final SupabaseClient _supabaseClient;

  DocumentsRepositoryImpl(this._supabaseClient);

  Future<void> _saveDocumentsToCache(List<dynamic> jsonList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_documents', jsonEncode(jsonList));
    } catch (e) {
      // ignore
    }
  }

  Future<List<DocumentEntity>> _getDocumentsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_documents');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => DocumentModel.fromJson(json).toEntity())
            .toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  @override
  Future<Either<Exception, List<DocumentEntity>>> getDocuments() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final response = await _supabaseClient
          .from('documentos')
          .select('*')
          .eq('user_id', userId)
          .order('data_envio', ascending: false);

      final List<dynamic> data = response as List;

      // Cache
      await _saveDocumentsToCache(data);

      final documents = data
          .map((json) => DocumentModel.fromJson(json).toEntity())
          .toList();

      return Right(documents);
    } catch (e) {
      // Try cache
      final cachedDocs = await _getDocumentsFromCache();
      if (cachedDocs.isNotEmpty) {
        return Right(cachedDocs);
      }
      return Left(Exception('Erro ao buscar documentos: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> uploadDocument({
    required DocumentType type,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      // 1. Upload file to Storage
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = 'documents/$userId/$fileName';

      await _supabaseClient.storage.from('files').upload(path, file);
      final publicUrl = _supabaseClient.storage
          .from('files')
          .getPublicUrl(path);

      // 2. Check if document already exists to update or insert
      final existingDoc = await _supabaseClient
          .from('documentos')
          .select('id')
          .eq('user_id', userId)
          .eq('tipo', type.name.toUpperCase())
          .maybeSingle();

      final docData = {
        'user_id': userId,
        'tipo': type.name.toUpperCase(),
        'status': 'PENDENTE',
        'foto_doc': publicUrl,
        'numero_documento': documentNumber,
        'validade_doc': expiryDate?.toIso8601String(),
        'data_envio': DateTime.now().toIso8601String(),
        'nome_documento': type.label,
      };

      if (existingDoc != null) {
        await _supabaseClient
            .from('documentos')
            .update(docData)
            .eq('id', existingDoc['id']);
      } else {
        await _supabaseClient.from('documentos').insert(docData);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao enviar documento: $e'));
    }
  }
}
