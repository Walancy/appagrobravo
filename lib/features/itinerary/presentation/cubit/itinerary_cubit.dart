import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../domain/entities/emergency_contacts.dart';
import '../../domain/repositories/itinerary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

part 'itinerary_state.dart';
part 'itinerary_cubit.freezed.dart';

@injectable
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;
  RealtimeChannel? _groupSubscription;

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

  Future<void> loadItinerary(String groupId, {bool isNewAssignment = false}) async {
    emit(const ItineraryState.loading());

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
              isNewAssignment: isNewAssignment,
            ));
          },
        );
      },
    );
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
          final prefs = await SharedPreferences.getInstance();
          final lastGroupId = prefs.getString('last_notified_group_id');
          final isNewAssignment = lastGroupId != null && lastGroupId != groupId;

          if (isNewAssignment || lastGroupId == null) {
             await prefs.setString('last_notified_group_id', groupId);
          }

          await loadItinerary(groupId, isNewAssignment: isNewAssignment);
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
            debugPrint('Group change detected for user. Reloading itinerary...');
            loadUserItinerary();
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _groupSubscription?.unsubscribe();
    return super.close();
  }
}
