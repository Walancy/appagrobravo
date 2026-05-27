import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../domain/entities/emergency_contacts.dart';
import '../../domain/entities/mission_material.dart';
import '../../domain/entities/checklist_item.dart';
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
          .select('*, missoes:missao_id(nome)')
          .eq('id', groupId)
          .single();

      final missao = response['missoes'] as Map<String, dynamic>?;
      response['missionName'] = missao?['nome'];

      // Cache the response
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_group_$groupId', jsonEncode(response));

      return Right(ItineraryGroupDto.fromJson(response).toEntity());
    } catch (e) {
      // Try cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cached_group_$groupId');
        if (cached != null) {
          final Map<String, dynamic> json = jsonDecode(cached);
          return Right(ItineraryGroupDto.fromJson(json).toEntity());
        }
      } catch (cacheError) {
        debugPrint('Erro ao ler cache de grupo: $cacheError');
      }
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<ItineraryItemEntity>>> getItinerary(
    String groupId,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;

      final response = await _supabaseClient
          .from('eventos')
          // INC-020: explicit columns to exclude percent_agrobravo/percent_cliente
          // BUG-FIX: removed non-existent columns (nome, hora_inicio2, imagem, attachments, deleted_at)
          .select(
            'id, titulo, subtitulo, tipo, data, hora_inicio, hora_fim,'
            ' descricao, localizacao, codigo_de,'
            ' codigo_para, de, para, hora_de, hora_para, atrasado, atraso,'
            ' motorista, duracao, tempo_deslocamento, conexoes, escalas,'
            ' endereco, cidade, estado, pais, latitude, longitude, rating,'
            ' estrelas, telefone, website, imagens, link_maps,'
            ' evento_referencia_id, is_day_after_transfer, dados, preco,'
            ' site_url, status, transfer_data, transfer_hora,'
            ' passageiros, place_id, grupo_id',
          )
          .eq('grupo_id', groupId)
          .order('data');
      // INC-024: hora_inicio is TEXT so DB sort is unreliable; app re-orders in memory

      final List<dynamic> data = response as List<dynamic>;

      // INC-002: keep only events where passageiros is empty/null OR contains this user
      final filtered = userId == null
          ? data
          : data.where((json) {
              final p = json['passageiros'];
              if (p == null) return true;
              if (p is List) return p.isEmpty || p.contains(userId);
              return true;
            }).toList();

      // Cache the response
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_itinerary_$groupId', jsonEncode(filtered));

      final items = filtered
          .map((json) => ItineraryItemDto.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      debugPrint('[REPO] getItinerary error: $e');
      // Try cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cached_itinerary_$groupId');
        if (cached != null) {
          final List<dynamic> data = jsonDecode(cached);
          final items = data
              .map((json) => ItineraryItemDto.fromJson(json).toEntity())
              .toList();
          return Right(items);
        }
      } catch (cacheError) {
        debugPrint('Erro ao ler cache de itinerário: $cacheError');
      }
      return Left(Exception(e.toString()));
    }
  }

  Future<void> _saveTravelTimesToCache(
    String groupId,
    List<dynamic> list,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_travel_times_$groupId', jsonEncode(list));
    } catch (e) {
      debugPrint('Erro ao salvar tempos de deslocamento no cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getTravelTimesFromCache(
    String groupId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_travel_times_$groupId');
      if (jsonString != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      }
    } catch (e) {
      debugPrint('Erro ao recuperar tempos de deslocamento do cache: $e');
    }
    return [];
  }

  Future<void> _saveUserGroupIdToCache(String? groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerId = _supabaseClient.auth.currentUser?.id ?? '';
      await prefs.setString('cached_user_group_id_owner', ownerId);
      if (groupId != null) {
        await prefs.setString('cached_user_group_id', groupId);
        await prefs.remove('cached_user_has_no_group');
      } else {
        await prefs.remove('cached_user_group_id');
        await prefs.setBool('cached_user_has_no_group', true);
      }
    } catch (e) {
      debugPrint('Erro ao salvar ID do grupo no cache: $e');
    }
  }

  Future<String?> _getUserGroupIdFromCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final owner = prefs.getString('cached_user_group_id_owner');
      if (owner != userId) return null; // cache belongs to a different user
      return prefs.getString('cached_user_group_id');
    } catch (e) {
      debugPrint('Erro ao recuperar ID do grupo do cache: $e');
    }
    return null;
  }

  Future<void> _savePendingDocsToCache(List<String> docs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_pending_docs', jsonEncode(docs));
    } catch (e) {
      debugPrint('Erro ao salvar documentos pendentes no cache: $e');
    }
  }

  Future<List<String>> _getPendingDocsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_pending_docs');
      if (jsonString != null) {
        return List<String>.from(jsonDecode(jsonString));
      }
    } catch (e) {
      debugPrint('Erro ao recuperar documentos pendentes do cache: $e');
    }
    return [];
  }

  Future<void> _saveMissionMaterialsToCache(
    String groupId,
    List<MissionMaterialEntity> materials,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = materials.map((material) => material.toJson()).toList();
      await prefs.setString(
        'cached_mission_materials_$groupId',
        jsonEncode(jsonList),
      );
    } catch (e) {
      debugPrint('Erro ao salvar materiais no cache: $e');
    }
  }

  Future<List<MissionMaterialEntity>> _getMissionMaterialsFromCache(
    String groupId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_mission_materials_$groupId');
      if (jsonString != null) {
        final List<dynamic> data = jsonDecode(jsonString);
        return data
            .map(
              (json) => MissionMaterialEntity.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .where((material) => material.url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao recuperar materiais do cache: $e');
    }
    return [];
  }

  Future<void> _saveEmergencyContactsToCache(EmergencyContacts contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'police': contacts.police,
        'firefighters': contacts.firefighters,
        'medical': contacts.medical,
        'countryName': contacts.countryName,
      };
      await prefs.setString('cached_emergency_contacts', jsonEncode(json));
    } catch (e) {
      debugPrint('Erro ao salvar contatos de emergência no cache: $e');
    }
  }

  Future<EmergencyContacts?> _getEmergencyContactsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_emergency_contacts');
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return EmergencyContacts(
          police: json['police'],
          firefighters: json['firefighters'],
          medical: json['medical'],
          countryName: json['countryName'],
        );
      }
    } catch (e) {
      debugPrint('Erro ao recuperar contatos de emergência do cache: $e');
    }
    return null;
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
      final list = List<Map<String, dynamic>>.from(data);
      await _saveTravelTimesToCache(groupId, list);

      return Right(list);
    } catch (e) {
      debugPrint(
        'Erro ao buscar tempos de deslocamento online: $e. Tentando cache.',
      );
      final cached = await _getTravelTimesFromCache(groupId);
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Exception('Erro ao buscar tempos de deslocamento: $e'));
    }
  }

  @override
  Future<Either<Exception, String?>> getUserGroupId() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    debugPrint('[REPO] getUserGroupId: userId=$userId');
    if (userId == null) return Left(Exception('Usuário não autenticado'));
    try {

      // BUG-FIX: user may belong to multiple groups — .maybeSingle() would throw.
      // Fetch all participations joined with group end date, then pick best.
      final response = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id, grupos!fk_gruposparticipantes_grupos(data_fim)')
          .eq('user_id', userId);

      final List<dynamic> rows = response as List<dynamic>;
      debugPrint('[REPO] getUserGroupId: rows retornadas=${rows.length} rawData=$rows');

      String? groupId;
      if (rows.isNotEmpty) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        debugPrint('[REPO] getUserGroupId: today=$today');

        // Only consider groups with data_fim >= today (active missions).
        // If user only has expired groups → treat as no active mission.
        final activeRows = rows
            .map((r) => r as Map<String, dynamic>)
            .where((r) {
              final gruposData = r['grupos'];
              final dateStr = (gruposData as Map<String, dynamic>?)?['data_fim'] as String?;
              final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
              final isActive = date != null && !date.isBefore(today);
              debugPrint('[REPO]   row grupo_id=${r['grupo_id']} grupos=$gruposData dateStr=$dateStr date=$date isActive=$isActive');
              return isActive;
            })
            .toList();

        debugPrint('[REPO] getUserGroupId: activeRows=${activeRows.length}');

        if (activeRows.isNotEmpty) {
          // Sort active groups by data_fim desc — pick the most recent
          activeRows.sort((a, b) {
            final aStr = (a['grupos'] as Map<String, dynamic>?)?['data_fim'] as String?;
            final bStr = (b['grupos'] as Map<String, dynamic>?)?['data_fim'] as String?;
            final aDate = aStr != null ? DateTime.tryParse(aStr) : null;
            final bDate = bStr != null ? DateTime.tryParse(bStr) : null;
            if (aDate != null && bDate != null) return bDate.compareTo(aDate);
            return 0;
          });
          groupId = activeRows.first['grupo_id'] as String?;
        }
        // else: user has groups but all expired → groupId stays null
      }

      debugPrint('[REPO] getUserGroupId: groupId final=$groupId');
      await _saveUserGroupIdToCache(groupId);

      // INC-011: mark participant as notified (fire-and-forget, non-blocking).
      // Only update when foiNotificado is still false — avoids triggering a
      // realtime UPDATE event on every call, which would create an infinite
      // listenToGroupChanges → loadUserItinerary loop.
      if (groupId != null) {
        _supabaseClient
            .from('gruposParticipantes')
            .update({'foiNotificado': true})
            .eq('user_id', userId)
            .eq('grupo_id', groupId)
            .eq('foiNotificado', false)
            .then((_) {})
            .catchError((_) {});
      }

      return Right(groupId);
    } catch (e, st) {
      debugPrint('[REPO] getUserGroupId: ERRO=$e\n$st');
      // Only use cache when it belongs to the current user
      final cached = await _getUserGroupIdFromCache(userId);
      debugPrint('[REPO] getUserGroupId: usando cache=$cached');
      if (cached != null) {
        return Right(cached);
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        final owner = prefs.getString('cached_user_group_id_owner');
        if (owner == userId) {
          final confirmedNoGroup = prefs.getBool('cached_user_has_no_group') ?? false;
          if (confirmedNoGroup) return const Right(null);
        }
      } catch (_) {}
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

      await _savePendingDocsToCache(docTypes);

      return Right(docTypes);
    } catch (e) {
      debugPrint(
        'Erro ao buscar documentos pendentes online: $e. Tentando cache.',
      );
      final cached = await _getPendingDocsFromCache();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<MissionMaterialEntity>>> getMissionMaterials(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('materiais')
          .select('id, nome, tamanho, url, created_at, updated_at')
          .eq('grupo_id', groupId)
          .eq('status', 'Visivel')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      final materials = data
          .map(
            (json) => MissionMaterialEntity.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .where((material) => material.url.isNotEmpty)
          .toList();

      await _saveMissionMaterialsToCache(groupId, materials);
      return Right(materials);
    } catch (e) {
      debugPrint('Erro ao buscar materiais online: $e. Tentando cache.');
      final cached = await _getMissionMaterialsFromCache(groupId);
      if (cached.isNotEmpty) {
        return Right(cached);
      }
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
          // BUG-008: add timeout to avoid hanging the emergency UI indefinitely
          final response = await http.get(
            url,
            headers: {'User-Agent': 'AgroBravoApp/1.0'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            countryName = data['address']?['country'];
          }
        } catch (e) {
          // Continue to error/cache
        }
      }

      if (countryName == null) {
        // Here we failed to get country. Try cache immediately.
        final cached = await _getEmergencyContactsFromCache();
        if (cached != null) return Right(cached);

        return Left(
          Exception('Não foi possível identificar o país desta localização.'),
        );
      }

      final countryRes = await _supabaseClient
          .from('paises')
          .select('id, pais')
          .or('pais.ilike.%$countryName%')
          .limit(1)
          .maybeSingle();

      int? paisId;
      String matchedCountry = countryName;

      if (countryRes != null) {
        paisId = countryRes['id'] as int;
        matchedCountry = countryRes['pais'] as String;
      }

      if (paisId == null) {
        // Try cache before error checking?
        // If we found a countryName but no DB entry, cache might be better if it exists?
        // But likely we have logic error or new country.
        // Let's check cache.
        final cached = await _getEmergencyContactsFromCache();
        if (cached != null) return Right(cached);

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
        final cached = await _getEmergencyContactsFromCache();
        if (cached != null) return Right(cached);

        return Left(
          Exception(
            'Dados de emergência não encontrados para $matchedCountry.',
          ),
        );
      }

      final contacts = EmergencyContacts(
        police: emergencyRes['policia'] ?? '190',
        firefighters: emergencyRes['bombeiro'] ?? '193',
        medical: emergencyRes['ambulancia'] ?? '192',
        countryName: matchedCountry,
      );

      await _saveEmergencyContactsToCache(contacts);

      return Right(contacts);
    } catch (e) {
      debugPrint(
        'Erro ao buscar contatos de emergência online: $e. Tentando cache.',
      );
      final cached = await _getEmergencyContactsFromCache();
      if (cached != null) {
        return Right(cached);
      }
      return Left(Exception('Erro ao buscar contatos de emergência: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ChecklistItemEntity>>> getChecklist(
    String groupId,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;

      // Fetch all items for this group
      final itemsRes = await _supabaseClient
          .from('grupoChecklist')
          .select('id, grupo_id, titulo, created_at')
          .eq('grupo_id', groupId)
          .order('created_at');

      final items = (itemsRes as List<dynamic>).map((row) {
        return ChecklistItemEntity(
          id: row['id'] as String,
          groupId: row['grupo_id'] as String,
          titulo: row['titulo'] as String,
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at'].toString())
              : null,
        );
      }).toList();

      if (items.isEmpty || userId == null) return Right(items);

      // Fetch which items the current user has checked
      final checkedRes = await _supabaseClient
          .from('respostasGruposChecklist')
          .select('checklist_id')
          .eq('user_id', userId);

      final checkedIds = (checkedRes as List<dynamic>)
          .map((row) => row['checklist_id'] as String)
          .toSet();

      for (final item in items) {
        item.isChecked = checkedIds.contains(item.id);
      }

      return Right(items);
    } catch (e) {
      return Left(Exception('Erro ao buscar checklist: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> toggleChecklistItem(
    String itemId,
    bool isChecked,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      if (isChecked) {
        await _supabaseClient.from('respostasGruposChecklist').upsert({
          'user_id': userId,
          'checklist_id': itemId,
        }, onConflict: 'user_id,checklist_id');
      } else {
        await _supabaseClient
            .from('respostasGruposChecklist')
            .delete()
            .eq('user_id', userId)
            .eq('checklist_id', itemId);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao salvar checklist: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> checkPrimeiraAcesso(String groupId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Right(false);

      final res = await _supabaseClient
          .from('gruposParticipantes')
          .select('primeiraAcesso')
          .eq('grupo_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      return Right(res?['primeiraAcesso'] as bool? ?? false);
    } catch (e) {
      return const Right(false);
    }
  }
}
