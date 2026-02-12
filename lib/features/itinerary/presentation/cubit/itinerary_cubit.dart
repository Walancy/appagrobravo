import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../../domain/repositories/itinerary_repository.dart';

part 'itinerary_state.dart';
part 'itinerary_cubit.freezed.dart';

@injectable
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;

  ItineraryCubit(this._repository) : super(const ItineraryState.initial());

  Future<void> loadItinerary(String groupId) async {
    emit(const ItineraryState.loading());

    final groupResult = await _repository.getGroupDetails(groupId);

    await groupResult.fold(
      (failure) async => emit(ItineraryState.error(failure.toString())),
      (group) async {
        final itemsResult = await _repository.getItinerary(groupId);
        final travelResult = await _repository.getTravelTimes(groupId);
        final pendingDocsResult = await _repository.getUserPendingDocuments();

        itemsResult.fold(
          (failure) => emit(ItineraryState.error(failure.toString())),
          (items) {
            travelResult.fold(
              (failure) => emit(ItineraryState.error(failure.toString())),
              (travelTimes) {
                pendingDocsResult.fold(
                  (failure) => emit(ItineraryState.error(failure.toString())),
                  (pendingDocs) => emit(
                    ItineraryState.loaded(
                      group,
                      items,
                      travelTimes,
                      pendingDocs,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> loadUserItinerary() async {
    emit(const ItineraryState.loading());
    final userGroupResult = await _repository.getUserGroupId();

    await userGroupResult.fold(
      (failure) async => emit(ItineraryState.error(failure.toString())),
      (groupId) async {
        if (groupId == null) {
          // User has no group
          // Could imply an empty state or specific error
          emit(
            const ItineraryState.error("Usuário não vinculado a nenhum grupo."),
          );
        } else {
          await loadItinerary(groupId);
        }
      },
    );
  }
}
