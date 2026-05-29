import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../domain/entities/emergency_contacts.dart';
import '../../domain/repositories/itinerary_repository.dart';
import 'package:agrobravo/core/services/onboarding_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;
import 'itinerary_state.dart';
export 'itinerary_state.dart';

@lazySingleton
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;
  RealtimeChannel? _groupSubscription;
  RealtimeChannel? _eventsSubscription;
  RealtimeChannel? _grupoSubscription;

  ItineraryCubit(this._repository) : super(const ItineraryState.initial());

  /// All active groups the user belongs to. Populated on every loadUserItinerary().
  List<ItineraryGroupEntity> activeGroups = [];

  String _mapFailure(Exception failure) {
    final message = failure.toString();
    if (message.contains('SocketException') ||
        message.contains('ClientException') ||
        message.contains('Network is unreachable') ||
        message.contains('Failed host lookup')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    }
    return message.replaceAll('Exception: ', '');
  }

  Future<void> loadItinerary(String groupId) async {
    debugPrint('[CUBIT] loadItinerary: groupId=$groupId');
    dev.log('[CUBIT] loadItinerary: groupId=$groupId', name: 'itinerary');
    emit(const ItineraryState.loading());

    final groupResult = await _repository.getGroupDetails(groupId);

    if (isClosed) return;

    await groupResult.fold(
      (failure) async {
        if (isClosed) return;
        debugPrint('[CUBIT] loadItinerary: FALHA getGroupDetails: $failure');
        dev.log('[CUBIT] loadItinerary: FALHA getGroupDetails: $failure', name: 'itinerary');
        emit(ItineraryState.error(_mapFailure(failure)));
      },
      (group) async {
        debugPrint('[CUBIT] loadItinerary: grupo carregado: ${group.id} nome=${group.name}');
        dev.log('[CUBIT] loadItinerary: grupo carregado: ${group.id} nome=${group.name}', name: 'itinerary');
        final itemsResult = await _repository.getItinerary(groupId);

        if (isClosed) return;

        await itemsResult.fold(
          (failure) async {
            if (isClosed) return;
            debugPrint('[CUBIT] loadItinerary: FALHA getItinerary: $failure');
            dev.log('[CUBIT] loadItinerary: FALHA getItinerary: $failure', name: 'itinerary');
            emit(ItineraryState.error(_mapFailure(failure)));
          },
          (items) async {
            // Non-critical data: Travel Times
            final travelResult = await _repository.getTravelTimes(groupId);
            if (isClosed) return;
            final travelTimes = travelResult.getOrElse(() => []);

            // Non-critical data: Pending Docs
            final pendingDocsResult = await _repository
                .getUserPendingDocuments();
            if (isClosed) return;
            final pendingDocs = pendingDocsResult.getOrElse(() => []);

            debugPrint('[CUBIT] loadItinerary: emitindo LOADED. group=${group.id}');
            dev.log('[CUBIT] loadItinerary: emitindo LOADED. group=${group.id}', name: 'itinerary');
            emit(ItineraryState.loaded(
              group,
              items,
              travelTimes,
              pendingDocs,
            ));

            // INC-004: subscribe to real-time changes for this group's events
            _subscribeToEventsChanges(groupId);
            // Subscribe to grupos so we detect when data_fim changes
            // (mission ends) and immediately leave the "inside mission" state.
            _subscribeToGrupoChanges(groupId);
          },
        );
      },
    );
  }

  /// Silently refreshes only the itinerary items (no loading spinner).
  Future<void> _refreshItemsSilently(String groupId) async {
    final currentState = state;
    final itemsResult = await _repository.getItinerary(groupId);
    if (isClosed) return;
    itemsResult.fold(
      (_) {}, // ignore error on background refresh
      (newItems) {
        if (isClosed) return;
        currentState.maybeWhen(
          loaded: (group, _, travelTimes, pendingDocs) {
            emit(ItineraryState.loaded(group, newItems, travelTimes, pendingDocs));
          },
          orElse: () {},
        );
      },
    );
  }

  void _subscribeToGrupoChanges(String groupId) {
    _grupoSubscription?.unsubscribe();
    final supabase = Supabase.instance.client;
    _grupoSubscription = supabase
        .channel('public:grupos:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'grupos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: groupId,
          ),
          callback: (payload) {
            dev.log('[CUBIT] _subscribeToGrupoChanges: EVENTO grupo=$groupId new=${payload.newRecord}', name: 'itinerary');
            loadUserItinerary();
          },
        )
        .subscribe((status, [error]) {
          dev.log('[CUBIT] _subscribeToGrupoChanges: subscription status=$status error=$error', name: 'itinerary');
        });
  }

  void _subscribeToEventsChanges(String groupId) {
    _eventsSubscription?.unsubscribe();
    final supabase = Supabase.instance.client;
    _eventsSubscription = supabase
        .channel('public:eventos:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'eventos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'grupo_id',
            value: groupId,
          ),
          callback: (_) {
            dev.log('Realtime: evento changed in group $groupId. Refreshing...');
            _refreshItemsSilently(groupId);
          },
        )
        .subscribe();
  }

  Future<void> loadUserItinerary() async {
    debugPrint('[CUBIT] loadUserItinerary: chamado. state=${state.runtimeType}');
    dev.log('[CUBIT] loadUserItinerary: chamado. state=${state.runtimeType}', name: 'itinerary');
    emit(const ItineraryState.loading());
    dev.log('[CUBIT] loadUserItinerary: emitido loading', name: 'itinerary');

    // Single source of truth: re-evaluate the onboarding gate on every load.
    // The router (refreshListenable) reacts and routes to /onboarding when
    // the user is in an active mission with primeiraAcesso still true.
    dev.log('[CUBIT] loadUserItinerary: chamando OnboardingService.refresh()...', name: 'itinerary');
    await OnboardingService.instance.refresh();
    if (isClosed) return;
    dev.log('[CUBIT] loadUserItinerary: needsOnboarding=${OnboardingService.instance.needsOnboarding}', name: 'itinerary');

    dev.log('[CUBIT] loadUserItinerary: chamando getUserGroupId()...', name: 'itinerary');
    final userGroupResult = await _repository.getUserGroupId();
    if (isClosed) return;

    await userGroupResult.fold(
      (failure) async {
        if (isClosed) return;
        debugPrint('[CUBIT] loadUserItinerary: FALHA no getUserGroupId: $failure');
        dev.log('[CUBIT] loadUserItinerary: FALHA no getUserGroupId: $failure', name: 'itinerary');
        emit(ItineraryState.error(_mapFailure(failure)));
      },
      (groupId) async {
        if (isClosed) return;
        debugPrint('[CUBIT] loadUserItinerary: groupId=$groupId');
        dev.log('[CUBIT] loadUserItinerary: groupId=$groupId', name: 'itinerary');
        if (groupId == null) {
          debugPrint('[CUBIT] loadUserItinerary: groupId=null → emitindo error (sem missão ativa)');
          dev.log('[CUBIT] loadUserItinerary: groupId=null → emitindo error (sem missão ativa)', name: 'itinerary');
          activeGroups = [];
          emit(
            const ItineraryState.error("Usuário não vinculado a nenhum grupo."),
          );
        } else {
          // Fetch all active groups (non-blocking, best-effort) so the
          // switch-group button knows how many missions the user is in.
          final allGroupsResult = await _repository.getActiveGroups();
          if (!isClosed) {
            allGroupsResult.fold(
              (_) => activeGroups = [],
              (groups) => activeGroups = groups,
            );
          }
          debugPrint('[CUBIT] loadUserItinerary: chamando loadItinerary($groupId)...');
          dev.log('[CUBIT] loadUserItinerary: chamando loadItinerary($groupId)...', name: 'itinerary');
          await loadItinerary(groupId);
        }
      },
    );
    debugPrint('[CUBIT] loadUserItinerary: finalizado. state final=${state.runtimeType}');
    dev.log('[CUBIT] loadUserItinerary: finalizado. state final=${state.runtimeType}', name: 'itinerary');
  }

  /// Switches the displayed itinerary to [groupId] without refetching activeGroups.
  Future<void> switchGroup(String groupId) => loadItinerary(groupId);

  Future<Either<Exception, EmergencyContacts>> getRepositoryEmergencyContacts(
    double lat,
    double lng,
  ) {
    return _repository.getEmergencyContacts(lat, lng);
  }

  void listenToGroupChanges() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    dev.log('[CUBIT] listenToGroupChanges: userId=$userId', name: 'itinerary');
    if (userId == null) return;

    _groupSubscription?.unsubscribe();
    _groupSubscription = supabase
        .channel('public:gruposParticipantes:itinerary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'gruposParticipantes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            dev.log('[CUBIT] listenToGroupChanges: EVENTO recebido! eventType=${payload.eventType} new=${payload.newRecord} old=${payload.oldRecord}', name: 'itinerary');
            loadUserItinerary();
          },
        )
        .subscribe((status, [error]) {
          dev.log('[CUBIT] listenToGroupChanges: subscription status=$status error=$error', name: 'itinerary');
        });
  }

  /// Cancels all subscriptions and resets to initial state.
  /// Must be called on logout so the next login triggers a full reload.
  void reset() {
    _groupSubscription?.unsubscribe();
    _groupSubscription = null;
    _eventsSubscription?.unsubscribe();
    _eventsSubscription = null;
    _grupoSubscription?.unsubscribe();
    _grupoSubscription = null;
    activeGroups = [];
    OnboardingService.instance.reset();
    emit(const ItineraryState.initial());
  }

  @override
  Future<void> close() {
    _groupSubscription?.unsubscribe();
    _eventsSubscription?.unsubscribe();
    _grupoSubscription?.unsubscribe();
    return super.close();
  }
}
