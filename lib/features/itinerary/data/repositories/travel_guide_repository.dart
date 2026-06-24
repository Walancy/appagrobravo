import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/itinerary/data/models/travel_guide_models.dart';

/// Repositório do Guia de Viagem.
///
/// Estratégia: Supabase direto (primário) + cache local (offline).
/// A API do painel Next.js é removida para evitar problemas de CORS/URL/deploy.
class TravelGuideRepository {
  final SupabaseClient _supabase;

  TravelGuideRepository(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  // ── Cache ─────────────────────────────────────────────────────────────────

  Future<void> _saveGuideToCache(String groupId, Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_travel_guide_$groupId', jsonEncode(json));
    } catch (e) {
      if (kDebugMode) dev.log('TravelGuide cache save error: $e');
    }
  }

  Future<Map<String, dynamic>?> _getGuideFromCache(String groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_travel_guide_$groupId');
      if (raw != null) return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) dev.log('TravelGuide cache read error: $e');
    }
    return null;
  }

  Future<void> _saveChecksToCache(
      String groupId, String userId, List<dynamic> checks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_travel_checks_${groupId}_$userId', jsonEncode(checks));
    } catch (e) {
      if (kDebugMode) dev.log('TravelGuide checks cache save error: $e');
    }
  }

  Future<List<dynamic>> _getChecksFromCache(
      String groupId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          prefs.getString('cached_travel_checks_${groupId}_$userId');
      if (raw != null) return jsonDecode(raw) as List<dynamic>;
    } catch (e) {
      if (kDebugMode) dev.log('TravelGuide checks cache read error: $e');
    }
    return [];
  }

  // ── Guia ──────────────────────────────────────────────────────────────────

  /// Busca o guia de viagem do grupo.
  /// Retorna `null` se não existir ou estiver oculto.
  Future<TravelGuide?> getGuide(String groupId) async {
    try {
      if (kDebugMode) dev.log('[TravelGuide] getGuide: groupId=$groupId');

      // 1. Busca o guia pelo grupo
      final guiaRow = await _supabase
          .from('guia_viagem')
          .select('id, grupo_id, titulo, status, created_at, updated_at')
          .eq('grupo_id', groupId)
          .maybeSingle();

      if (kDebugMode) dev.log('[TravelGuide] guiaRow=$guiaRow');

      if (guiaRow == null) {
        if (kDebugMode) dev.log('[TravelGuide] Nenhum guia encontrado para grupo=$groupId');
        return null;
      }

      final status = guiaRow['status'] as String? ?? 'Oculto';
      if (status != 'Visivel') {
        if (kDebugMode) dev.log('[TravelGuide] Guia oculto (status=$status)');
        return null;
      }

      // 2. Busca os cards
      final guiaId = guiaRow['id'] as String;
      final cardsRows = await _supabase
          .from('guia_viagem_cards')
          .select('id, guia_id, titulo, icone, descricao, ordem')
          .eq('guia_id', guiaId)
          .order('ordem');

      if (kDebugMode) dev.log('[TravelGuide] cards encontrados: ${(cardsRows as List).length}');

      final json = <String, dynamic>{
        ...guiaRow,
        'guia_viagem_cards': cardsRows,
      };

      // Salva no cache
      await _saveGuideToCache(groupId, json);

      return TravelGuide.fromJson(json);
    } catch (e) {
      if (kDebugMode) dev.log('[TravelGuide] getGuide ERRO: $e');

      // Fallback: cache local
      final cached = await _getGuideFromCache(groupId);
      if (cached != null) {
        if (kDebugMode) dev.log('[TravelGuide] Usando cache local');
        final guide = TravelGuide.fromJson(cached);
        return guide.isVisible ? guide : null;
      }
      return null;
    }
  }

  // ── Checks ────────────────────────────────────────────────────────────────

  /// Busca o progresso do viajante para o guia do grupo.
  Future<List<CardCheck>> getChecks(String groupId) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      // Pega o ID do guia deste grupo
      final guiaRow = await _supabase
          .from('guia_viagem')
          .select('id')
          .eq('grupo_id', groupId)
          .maybeSingle();

      if (guiaRow == null) return [];
      final guiaId = guiaRow['id'] as String;

      // Pega os IDs dos cards
      final cardsRows = await _supabase
          .from('guia_viagem_cards')
          .select('id')
          .eq('guia_id', guiaId);

      final cardIds = (cardsRows as List<dynamic>)
          .map((r) => r['id'] as String)
          .toList();

      if (cardIds.isEmpty) return [];

      // Busca os checks do usuário para esses cards
      final checksRows = await _supabase
          .from('guia_viagem_card_checks')
          .select('card_id, concluido, checked_at')
          .eq('user_id', userId)
          .inFilter('card_id', cardIds);

      final data = checksRows as List<dynamic>;
      await _saveChecksToCache(groupId, userId, data);

      return data
          .map((e) => CardCheck.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) dev.log('[TravelGuide] getChecks ERRO: $e');

      // Fallback: cache local
      final cached = await _getChecksFromCache(groupId, userId);
      return cached
          .map((e) => CardCheck.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  /// Marca ou desmarca um card como concluído. Retorna `true` em sucesso.
  Future<bool> toggleCheck({
    required String cardId,
    required bool concluido,
  }) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      await _supabase.from('guia_viagem_card_checks').upsert(
        {
          'card_id': cardId,
          'user_id': userId,
          'concluido': concluido,
          'checked_at': concluido ? DateTime.now().toIso8601String() : null,
        },
        onConflict: 'card_id,user_id',
      );
      if (kDebugMode) {
        dev.log('[TravelGuide] toggleCheck card=$cardId concluido=$concluido OK');
      }
      return true;
    } catch (e) {
      if (kDebugMode) dev.log('[TravelGuide] toggleCheck ERRO: $e');
      return false;
    }
  }

  // ── Toggle All ────────────────────────────────────────────────────────────

  /// Marca ou desmarca todos os cards de um guia como concluídos de uma vez.
  /// Retorna `true` em sucesso.
  Future<bool> toggleAllChecks({
    required List<String> cardIds,
    required bool concluido,
  }) async {
    final userId = _userId;
    if (userId == null) return false;

    if (cardIds.isEmpty) return true;

    try {
      final now = concluido ? DateTime.now().toIso8601String() : null;
      final payload = cardIds.map((id) => {
        'card_id': id,
        'user_id': userId,
        'concluido': concluido,
        'checked_at': now,
      }).toList();

      await _supabase.from('guia_viagem_card_checks').upsert(
        payload,
        onConflict: 'card_id,user_id',
      );
      if (kDebugMode) {
        dev.log('[TravelGuide] toggleAllChecks concluido=$concluido OK para ${cardIds.length} cards');
      }
      return true;
    } catch (e) {
      if (kDebugMode) dev.log('[TravelGuide] toggleAllChecks ERRO: $e');
      return false;
    }
  }
}
