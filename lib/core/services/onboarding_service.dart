import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/itinerary/domain/entities/itinerary_group.dart';

/// Global singleton that drives the onboarding gate.
/// GoRouter listens to this ChangeNotifier via refreshListenable.
class OnboardingService extends ChangeNotifier {
  static final OnboardingService instance = OnboardingService._();
  OnboardingService._();

  bool _needsOnboarding = false;
  String? _groupId;
  ItineraryGroupEntity? _group;

  bool get needsOnboarding => _needsOnboarding;
  ItineraryGroupEntity? get group => _group;

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

  /// Persists onboarding answers and clears the gate.
  /// Uses a SECURITY DEFINER RPC to bypass RLS on gruposParticipantes.
  /// Does NOT call notifyListeners here — OnboardingPage manages the
  /// post-submit guide step before navigating away.
  Future<void> completeOnboarding({
    String? familiaresViajantes,
    String? particularidades,
    bool? autorizaImagem,
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
    });
  }

  /// Guarantees primeiraAcesso = false in DB and unblocks navigation.
  /// Idempotent — safe to call even if completeOnboarding() was called before.
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
    _needsOnboarding = false;
    _groupId = null;
    _group = null;
    // Do NOT call notifyListeners here — GoRouter may not have a valid
    // context during logout. The caller manages navigation.
  }
}
