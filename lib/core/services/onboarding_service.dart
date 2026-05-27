import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';
import 'package:agrobravo/features/itinerary/data/models/itinerary_group_dto.dart';
import 'dart:developer' as dev;

/// Global singleton that drives the onboarding gate.
/// GoRouter listens to this ChangeNotifier via refreshListenable.
class OnboardingService extends ChangeNotifier {
  static final OnboardingService instance = OnboardingService._();
  OnboardingService._();

  bool _needsOnboarding = false;
  String? _groupId;
  ItineraryGroupEntity? _group;
  RealtimeChannel? _subscription;

  bool get needsOnboarding => _needsOnboarding;
  ItineraryGroupEntity? get group => _group;

  /// Call immediately after the user authenticates (login, register, app resume).
  /// Does an immediate DB check then subscribes real-time to gruposParticipantes.
  /// Must complete before AuthCubit emits authenticated so GoRouter can route
  /// directly to /onboarding when primeiraAcesso = true — no flash.
  Future<void> initialize(String userId) async {
    await _subscription?.unsubscribe();
    _subscription = null;

    final supabase = Supabase.instance.client;

    await _checkForUser(userId, supabase);

    _subscription = supabase
        .channel('onboarding:gp:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'gruposParticipantes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) {
            dev.log('OnboardingService: gruposParticipantes changed, rechecking...');
            _checkForUser(userId, supabase);
          },
        )
        .subscribe();
  }

  Future<void> _checkForUser(String userId, SupabaseClient supabase) async {
    try {
      // STEP 1 — simplest possible query: the user's own participation rows.
      // Single table, covered by the "read own gruposParticipantes" RLS policy,
      // no joins/embeds that could throw and abort the whole check.
      final parts = await supabase
          .from('gruposParticipantes')
          .select('grupo_id, primeiraAcesso')
          .eq('user_id', userId);

      final candidates = (parts as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((r) => r['primeiraAcesso'] == true)
          .map((r) => r['grupo_id'] as String)
          .toList();

      dev.log(
        '[ONB] _checkForUser userId=$userId parts=${parts.length} '
        'firstAccessCandidates=${candidates.length}',
        name: 'onboarding',
      );

      if (candidates.isEmpty) {
        _clearIfNeeded();
        return;
      }

      // STEP 2 — fetch the candidate groups and keep only active (not ended)
      // ones. Same "active mission" rule the itinerary uses.
      final groupsRes = await supabase
          .from('grupos')
          .select('id, nome, data_inicio, data_fim, missoes:missao_id(nome)')
          .inFilter('id', candidates);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Map<String, dynamic>? match;
      for (final raw in (groupsRes as List)) {
        final g = Map<String, dynamic>.from(raw as Map);
        final endStr = g['data_fim'] as String?;
        final end = endStr != null ? DateTime.tryParse(endStr) : null;
        if (end == null || end.isBefore(today)) continue;
        match = g;
        break;
      }

      if (match == null) {
        dev.log(
          '[ONB] _checkForUser: candidate groups all ended/invalid '
          '(fetched=${groupsRes.length})',
          name: 'onboarding',
        );
        _clearIfNeeded();
        return;
      }

      final groupData = Map<String, dynamic>.from(match);
      final missaoData = groupData['missoes'] as Map<String, dynamic>?;
      groupData['missionName'] = missaoData?['nome'];

      final group = ItineraryGroupDto.fromJson(groupData).toEntity();
      dev.log('[ONB] _checkForUser: MATCH grupo=${group.id} -> needsOnboarding=true',
          name: 'onboarding');
      setNeedsOnboarding(true, groupId: group.id, group: group);
    } catch (e, st) {
      dev.log('[ONB] _checkForUser error: $e', name: 'onboarding', stackTrace: st);
      // Fail silently — do not block the user on transient network error
    }
  }

  void _clearIfNeeded() {
    if (_needsOnboarding) {
      _needsOnboarding = false;
      _groupId = null;
      _group = null;
      notifyListeners();
    }
  }

  /// Lightweight re-check of the onboarding gate using the current session.
  /// Unlike [initialize], it does NOT tear down/rebuild the realtime
  /// subscription, so it is safe to call on every screen load.
  Future<void> refresh() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    dev.log('[ONB] refresh: userId=$userId _needsOnboarding=$_needsOnboarding', name: 'onboarding');
    if (userId == null) return;
    await _checkForUser(userId, supabase);
    dev.log('[ONB] refresh: após _checkForUser → _needsOnboarding=$_needsOnboarding', name: 'onboarding');
  }

  void setNeedsOnboarding(
    bool value, {
    String? groupId,
    ItineraryGroupEntity? group,
  }) {
    final changed = _needsOnboarding != value || _groupId != groupId;
    _needsOnboarding = value;
    if (groupId != null) _groupId = groupId;
    if (group != null) _group = group;
    if (changed) notifyListeners();
  }

  /// Persists ALL onboarding answers to gruposParticipantes and sets
  /// primeiraAcesso=false via SECURITY DEFINER RPC (bypasses RLS).
  /// Does NOT call notifyListeners — the guide step is shown next and
  /// clearGate() unblocks navigation when the user taps "Ir para o app".
  Future<void> completeOnboarding({
    String? familiaresViajantes,
    String? particularidades,
    bool? autorizaImagem,
    bool? concordaDeclaracao,
  }) async {
    if (_groupId == null) return;
    final supabase = Supabase.instance.client;

    await supabase.rpc('complete_onboarding', params: {
      'p_grupo_id': _groupId,
      if (familiaresViajantes != null && familiaresViajantes.isNotEmpty)
        'p_familiares': familiaresViajantes,
      if (particularidades != null && particularidades.isNotEmpty)
        'p_particularidades': particularidades,
      if (autorizaImagem != null) 'p_autoriza_imagem': autorizaImagem,
      if (concordaDeclaracao != null) 'p_concorda_declaracao': concordaDeclaracao,
    });
  }

  /// Clears the onboarding gate locally and notifies the router.
  /// Call after completeOnboarding() has already persisted to DB — no
  /// second RPC needed, saving one network round-trip.
  void clearGate() {
    _needsOnboarding = false;
    notifyListeners();
  }

  /// Legacy safety-net: persists primeiraAcesso=false if completeOnboarding
  /// was never called, then clears the gate. Kept for external callers.
  Future<void> dismiss() async {
    if (_groupId != null) {
      try {
        await Supabase.instance.client.rpc(
          'complete_onboarding',
          params: {'p_grupo_id': _groupId},
        );
      } catch (_) {}
    }
    _needsOnboarding = false;
    notifyListeners();
  }

  /// Resets all onboarding state. Call on logout so the next login
  /// triggers a fresh check of primeiraAcesso.
  void reset() {
    _subscription?.unsubscribe();
    _subscription = null;
    _needsOnboarding = false;
    _groupId = null;
    _group = null;
    // Do NOT call notifyListeners here — GoRouter may not have a valid
    // context during logout. The caller manages navigation.
  }
}
