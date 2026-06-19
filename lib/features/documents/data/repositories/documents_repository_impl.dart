import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
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
    String? id,
    required DocumentType type,
    File? file,
    String? documentNumber,
    DateTime? expiryDate,
    String? documentName,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      String? publicUrl;

      // Only upload file if a new one is provided
      if (file != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final path = 'documents/$userId/$fileName';

        await _supabaseClient.storage.from('files').upload(path, file);
        publicUrl = _supabaseClient.storage
            .from('files')
            .getPublicUrl(path);
      }

      final docData = <String, dynamic>{
        'user_id': userId,
        'tipo': _documentTypeToDb(type),
        'status': 'PENDENTE',
        'numero_documento': documentNumber,
        'validade_doc': expiryDate?.toIso8601String(),
        'data_envio': DateTime.now().toIso8601String(),
        'nome_documento': documentName ?? type.label,
      };

      // Only include foto_doc if we have a new file
      if (publicUrl != null) {
        docData['foto_doc'] = publicUrl;
      }

      if (id != null) {
        // Update existing document in history
        await _supabaseClient
            .from('documentos')
            .update(docData)
            .eq('id', id);
      } else {
        // Insert new document — requires a file
        if (publicUrl == null) {
          return Left(Exception('Arquivo é obrigatório para novo documento.'));
        }
        docData['foto_doc'] = publicUrl;
        await _supabaseClient.from('documentos').insert(docData);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao enviar documento: $e'));
    }
  }

  String _documentTypeToDb(DocumentType type) {
    switch (type) {
      case DocumentType.passaporte:
        return 'PASSAPORTE';
      case DocumentType.visto:
        return 'VISTO';
      case DocumentType.vacina:
        return 'VACINA';
      case DocumentType.seguro:
        return 'SEGURO';
      case DocumentType.carteiraMotorista:
        return 'CARTEIRA_MOTORISTA';
      case DocumentType.autorizacaoMenores:
        return 'AUTORIZACAO_MENORES';
      case DocumentType.outro:
        return 'OUTRO';
    }
  }

  static const String _systemPrompt = '''
You are an expert at extracting data from travel documents (visas, passports). 
Given an image of a visa or passport, extract the following fields and return ONLY a valid JSON object, no markdown or explanation.
Use null for any field you cannot read or that does not apply.

Required JSON shape:
{
  "document_kind": "passport" or "visa" - REQUIRED. Identify whether the image shows a PASSPORT or a VISA. Return exactly one of these two words.",
  "surname": "string or null",
  "given_name": "string or null",
  "issue_date": "DD/MM/YYYY or null",
  "expiration_date": "DD/MM/YYYY or null",
  "country": "ISO 2-letter code or country name (e.g. us, USA, Brazil) or null",
  "visa_origin": "string or null - For VISAS only: identify which country issued the visa and return a short label in Portuguese (e.g. Americano, Chinês, Britânico, Japonês, Canadense, Australiano, Schengen). Use null for passports or if not a visa.",
  "visa_number": "string or null (for visas; Control Number on US visas)",
  "visa_type": "string or null (e.g. B1/B2)",
  "passport_number": "string or null (for passports)"
}

Rules:
- document_kind: MUST be "passport" if the document is a passport (national passport booklet), or "visa" if it is a visa (sticker, visa page, or visa-only document). No other values.
- Dates: use DD/MM/YYYY format. If you see 21MAY2033, return "21/05/2033".
- Names: use the exact spelling from the document (Surname and Given Name as labeled).
- Country: prefer 2-letter code (us, br) or full name.
- visa_origin: only for visas; use Portuguese adjective (Americano, Chinês, Britânico, etc.). One word when possible.
- Return only the JSON object, no other text.
''';

  Future<Either<Exception, Map<String, dynamic>>> _parseDocumentDirectOpenAI({
    required DocumentType type,
    required File file,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return Left(Exception('OpenAI API key não encontrada no .env do app.'));
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final userPrompt = type == DocumentType.passaporte
          ? 'Extract all fields from this passport image. Return only the JSON object.'
          : 'Extract all fields from this visa image (Surname, Given Name, Issue Date, Expiration Date, Country, Visa Number, Visa Type). Return only the JSON object.';

      final mimeType = file.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,$base64Image';

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': userPrompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': dataUrl},
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices']?[0]?['message']?['content'];
        if (content != null && content is String) {
          final Map<String, dynamic> parsedData = jsonDecode(content);
          return Right(parsedData);
        }
        return Left(Exception('Formato de resposta da OpenAI inválido.'));
      } else {
        return Left(Exception('Erro da OpenAI: ${response.statusCode} - ${response.body}'));
      }
    } catch (e) {
      return Left(Exception('Falha no processamento direto com a OpenAI: $e'));
    }
  }

  @override
  Future<Either<Exception, Map<String, dynamic>>> parseDocument({
    required DocumentType type,
    required File file,
  }) async {
    // 1. Tentar o servidor do painel primeiro (porta 3000)
    try {
      final url = Uri.parse('http://192.168.18.221:3000/api/documents/parse');
      final request = http.MultipartRequest('POST', url);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
      
      request.fields['type'] = type.name.toUpperCase();
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 4));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Right(data);
      }
      throw Exception('HTTP error code: ${response.statusCode}');
    } catch (e) {
      // 2. Fallback: Se der erro de conexão, timeout ou qualquer outro, roda o OCR direto no app
      debugPrint('Falha de conexão com o painel ($e). Executando processamento local direto com OpenAI...');
      return await _parseDocumentDirectOpenAI(type: type, file: file);
    }
  }
}
