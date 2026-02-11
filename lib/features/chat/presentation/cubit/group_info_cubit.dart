import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrobravo/features/chat/presentation/cubit/group_info_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class GroupInfoCubit extends Cubit<GroupInfoState> {
  final ChatRepository _repository;

  GroupInfoCubit(this._repository) : super(const GroupInfoState.initial());

  Future<void> loadGroupDetails(String groupId) async {
    emit(const GroupInfoState.loading());
    final result = await _repository.getGroupDetails(groupId);
    result.fold(
      (error) => emit(GroupInfoState.error(error.toString())),
      (details) => emit(GroupInfoState.loaded(details)),
    );
  }
}
