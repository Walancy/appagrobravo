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
import 'dart:developer' as dev;

part 'itinerary_state.dart';
part 'itinerary_cubit.freezed.dart';

@injectable
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;
  RealtimeChannel? _groupSubscription;
  RealtimeChannel? _eventsSubscription;
  RealtimeChannel? _grupoSubscription;

  ItineraryCubit(this._repository) : super(const ItineraryState.initial());

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
    dev.log('[CUBIT] loadItinerary: groupId=$groupId', name: 'itinerary');
    emit(const ItineraryState.loading());

    final groupResult = await _repository.getGroupDetails(groupId);

    groupResult.fold(
      (failure) {
        dev.log('[CUBIT] loadItinerary: FALHA getGroupDetails: $failure', name: 'itinerary');
        emit(ItineraryState.error(_mapFailure(failure)));
      },
      (group) async {
        dev.log('[CUBIT] loadItinerary: grupo carregado: ${group.id} nome=${group.name}', name: 'itinerary');
        final itemsResult = await _repository.getItinerary(groupId);

        itemsResult.fold(
          (failure) {
            dev.log('[CUBIT] loadItinerary: FALHA getItinerary: $failure', name: 'itinerary');
            emit(ItineraryState.error(_mapFailure(failure)));
          },
          (items) async {
            dev.log('[CUBIT] loadItinerary: items=${items.length}', name: 'itinerary');
            // Non-critical data: Travel Times
            final travelResult = await _repository.getTravelTimes(groupId);
            final travelTimes = travelResult.getOrElse(() => []);

            // Non-critical data: Pending Docs
            final pendingDocsResult = await _repository
                .getUserPendingDocuments();
            final pendingDocs = pendingDocsResult.getOrElse(() => []);

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
    itemsResult.fold(
      (_) {}, // ignore error on background refresh
      (newItems) {
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
    dev.log('[CUBIT] loadUserItinerary: chamado. state=${state.runtimeType}', name: 'itinerary');
    emit(const ItineraryState.loading());
    dev.log('[CUBIT] loadUserItinerary: emitido loading', name: 'itinerary');

    // Single source of truth: re-evaluate the onboarding gate on every load.
    // The router (refreshListenable) reacts and routes to /onboarding when
    // the user is in an active mission with primeiraAcesso still true.
    dev.log('[CUBIT] loadUserItinerary: chamando OnboardingService.refresh()...', name: 'itinerary');
    await OnboardingService.instance.refresh();
    dev.log('[CUBIT] loadUserItinerary: needsOnboarding=${OnboardingService.instance.needsOnboarding}', name: 'itinerary');

    dev.log('[CUBIT] loadUserItinerary: chamando getUserGroupId()...', name: 'itinerary');
    final userGroupResult = await _repository.getUserGroupId();

    await userGroupResult.fold(
      (failure) async {
        dev.log('[CUBIT] loadUserItinerary: FALHA no getUserGroupId: $failure', name: 'itinerary');
        emit(ItineraryState.error(_mapFailure(failure)));
      },
      (groupId) async {
        dev.log('[CUBIT] loadUserItinerary: groupId=$groupId', name: 'itinerary');
        if (groupId == null) {
          dev.log('[CUBIT] loadUserItinerary: groupId=null → emitindo error (sem missão ativa)', name: 'itinerary');
          emit(
            const ItineraryState.error("Usuário não vinculado a nenhum grupo."),
          );
        } else {
          dev.log('[CUBIT] loadUserItinerary: chamando loadItinerary($groupId)...', name: 'itinerary');
          await loadItinerary(groupId);
        }
      },
    );
    dev.log('[CUBIT] loadUserItinerary: finalizado. state final=${state.runtimeType}', name: 'itinerary');
  }

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
