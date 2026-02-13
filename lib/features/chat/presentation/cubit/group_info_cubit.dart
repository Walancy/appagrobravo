import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrobravo/features/chat/presentation/cubit/group_info_state.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GroupInfoCubit extends Cubit<GroupInfoState> {
  final ChatRepository _chatRepository;
  final ProfileRepository _profileRepository;

  GroupInfoCubit(this._chatRepository, this._profileRepository)
    : super(const GroupInfoState.initial());

  Future<void> loadGroupDetails(String groupId) async {
    emit(const GroupInfoState.loading());
    final result = await _chatRepository.getGroupDetails(groupId);
    result.fold(
      (error) => emit(GroupInfoState.error(error.toString())),
      (details) => emit(GroupInfoState.loaded(details)),
    );
  }

  Future<void> requestConnection(String groupId, String userId) async {
    final result = await _profileRepository.requestConnection(userId);
    result.fold(
      (error) => null, // Handle error UI if needed
      (_) => loadGroupDetails(groupId), // Refresh to show pending status
    );
  }
}
