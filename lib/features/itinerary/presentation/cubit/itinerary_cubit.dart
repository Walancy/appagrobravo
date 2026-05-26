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
  String? _currentGroupId;

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
    emit(const ItineraryState.loading());
    _currentGroupId = groupId;

    final groupResult = await _repository.getGroupDetails(groupId);

    groupResult.fold(
      (failure) => emit(ItineraryState.error(_mapFailure(failure))),
      (group) async {
        final itemsResult = await _repository.getItinerary(groupId);

        itemsResult.fold(
          (failure) => emit(ItineraryState.error(_mapFailure(failure))),
          (items) async {
            // Non-critical data: Travel Times
            final travelResult = await _repository.getTravelTimes(groupId);
            final travelTimes = travelResult.getOrElse(() => []);

            // Non-critical data: Pending Docs
            final pendingDocsResult = await _repository
                .getUserPendingDocuments();
            final pendingDocs = pendingDocsResult.getOrElse(() => []);

            emit(ItineraryState.loaded(
              group,
              items,
              travelTimes,
              pendingDocs,
            ));

            // INC-004: subscribe to real-time changes for this group's events
            _subscribeToEventsChanges(groupId);

            // Onboarding gate: check primeiraAcesso for this group/user
            _checkPrimeiraAcesso(groupId, group);
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

  Future<void> _checkPrimeiraAcesso(
    String groupId,
    ItineraryGroupEntity group,
  ) async {
    final result = await _repository.checkPrimeiraAcesso(groupId);
    result.fold(
      (_) {},
      (primeiraAcesso) {
        OnboardingService.instance.setNeedsOnboarding(
          primeiraAcesso,
          groupId: groupId,
          group: group,
        );
      },
    );
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
    emit(const ItineraryState.loading());
    final userGroupResult = await _repository.getUserGroupId();

    userGroupResult.fold(
      (failure) => emit(ItineraryState.error(_mapFailure(failure))),
      (groupId) async {
        if (groupId == null) {
          emit(
            const ItineraryState.error("Usuário não vinculado a nenhum grupo."),
          );
        } else {
          await loadItinerary(groupId);
        }
      },
    );
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
            dev.log('Group change detected for user. Reloading itinerary...');
            loadUserItinerary();
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _groupSubscription?.unsubscribe();
    _eventsSubscription?.unsubscribe();
    return super.close();
  }
}
