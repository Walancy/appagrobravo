import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/itinerary_repository.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../domain/entities/emergency_contacts.dart';
import '../models/itinerary_group_dto.dart';
import '../models/itinerary_item_dto.dart';

@LazySingleton(as: ItineraryRepository)
class ItineraryRepositoryImpl implements ItineraryRepository {
  final SupabaseClient _supabaseClient;

  ItineraryRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, ItineraryGroupEntity>> getGroupDetails(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('grupos')
          .select()
          .eq('id', groupId)
          .single();

      return Right(ItineraryGroupDto.fromJson(response).toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<ItineraryItemEntity>>> getItinerary(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('eventos')
          .select()
          .eq('grupo_id', groupId)
          .order('data')
          .order('hora_inicio');

      final List<dynamic> data = response as List<dynamic>;
      final items = data
          .map((json) => ItineraryItemDto.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Map<String, dynamic>>>> getTravelTimes(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient.rpc(
        'buscar_itinerario_grupo_deslocamento',
        params: {'p_grupo_id': groupId},
      );

      final List<dynamic> data = response as List<dynamic>;
      return Right(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return Left(Exception('Erro ao buscar tempos de deslocamento: $e'));
    }
  }

  @override
  Future<Either<Exception, String?>> getUserGroupId() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final response = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return const Right(null);

      return Right(response['grupo_id'] as String?);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<String>>> getUserPendingDocuments() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final response = await _supabaseClient
          .from('documentos')
          .select('tipo, nome_documento')
          .eq('user_id', userId)
          .eq('status', 'PENDENTE');

      final List<dynamic> data = response as List<dynamic>;
      final docTypes = data.map((doc) {
        final type = doc['tipo']?.toString();
        if (type != null && type.isNotEmpty) {
          return type[0].toUpperCase() + type.substring(1).toLowerCase();
        }
        return doc['nome_documento']?.toString() ?? 'Documento';
      }).toList();

      return Right(docTypes);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, EmergencyContacts>> getEmergencyContacts(
    double lat,
    double lng,
  ) async {
    try {
      String? countryName;

      // 1. Try mobile-native geocoding first (not on Web)
      if (!kIsWeb) {
        try {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            countryName = placemarks.first.country;
          }
        } catch (e) {
          // Failure on mobile geocoding, will try fallback below
        }
      }

      // 2. Web fallback or if mobile native geocoding failed
      if (countryName == null) {
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AgroBravoApp/1.0'},
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            countryName = data['address']?['country'];
          }
        } catch (e) {
          return Left(
            Exception(
              'Não foi possível determinar o país pela localização (Web Fallback): $e',
            ),
          );
        }
      }

      if (countryName == null) {
        return Left(
          Exception('Não foi possível identificar o país desta localização.'),
        );
      }

      final countryRes = await _supabaseClient
          .from('paises')
          .select('id, pais')
          .or('pais.ilike.%$countryName%')
          .maybeSingle();

      int? paisId;
      String matchedCountry = countryName;

      if (countryRes != null) {
        paisId = countryRes['id'] as int;
        matchedCountry = countryRes['pais'] as String;
      }

      if (paisId == null) {
        return Left(
          Exception(
            'Contatos de emergência não configurados para $countryName.',
          ),
        );
      }

      final emergencyRes = await _supabaseClient
          .from('chamada_emergencia')
          .select()
          .eq('pais_id', paisId)
          .maybeSingle();

      if (emergencyRes == null) {
        return Left(
          Exception(
            'Dados de emergência não encontrados para $matchedCountry.',
          ),
        );
      }

      return Right(
        EmergencyContacts(
          police: emergencyRes['policia'] ?? '190',
          firefighters: emergencyRes['bombeiro'] ?? '193',
          medical: emergencyRes['ambulancia'] ?? '192',
          countryName: matchedCountry,
        ),
      );
    } catch (e) {
      return Left(Exception('Erro ao buscar contatos de emergência: $e'));
    }
  }
}
