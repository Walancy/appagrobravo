import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileCubit(this._profileRepository, this._authRepository)
    : super(const ProfileState.initial());

  Future<void> loadProfile([String? userId]) async {
    emit(const ProfileState.loading());

    try {
      String? targetUserId = userId;
      bool isMe = false;

      if (targetUserId == null) {
        final userOption = await _authRepository.getCurrentUser();
        targetUserId = userOption.fold(() => null, (user) => user.id);
        isMe = true;
      } else {
        final userOption = await _authRepository.getCurrentUser();
        final currentId = userOption.fold(() => null, (user) => user.id);
        isMe = targetUserId == currentId;
      }

      if (targetUserId == null) {
        emit(const ProfileState.error('Usuário não autenticado'));
        return;
      }

      final profileResult = await _profileRepository.getProfile(targetUserId);
      final postsResult = await _profileRepository.getUserPosts(targetUserId);

      profileResult.fold(
        (error) => emit(ProfileState.error(error.toString())),
        (profile) {
          postsResult.fold(
            (error) => emit(ProfileState.error(error.toString())),
            (posts) => emit(
              ProfileState.loaded(profile: profile, posts: posts, isMe: isMe),
            ),
          );
        },
      );
    } catch (e) {
      emit(ProfileState.error('Erro ao carregar perfil: $e'));
    }
  }

  Future<void> updateProfilePhoto(XFile file) async {
    state.maybeMap(
      loaded: (currentState) async {
        final bytes = await file.readAsBytes();
        final extension = file.path.split('.').last;
        final result = await _profileRepository.updateProfilePhoto(
          bytes,
          extension,
        );

        result.fold((error) => emit(ProfileState.error(error.toString())), (
          newUrl,
        ) {
          emit(
            currentState.copyWith(
              profile: currentState.profile.copyWith(avatarUrl: newUrl),
            ),
          );
        });
      },
      orElse: () {},
    );
  }

  Future<void> updateCoverPhoto(XFile file) async {
    state.maybeMap(
      loaded: (currentState) async {
        final bytes = await file.readAsBytes();
        final extension = file.path.split('.').last;
        final result = await _profileRepository.updateCoverPhoto(
          bytes,
          extension,
        );

        result.fold((error) => emit(ProfileState.error(error.toString())), (
          newUrl,
        ) {
          emit(
            currentState.copyWith(
              profile: currentState.profile.copyWith(coverUrl: newUrl),
            ),
          );
        });
      },
      orElse: () {},
    );
  }

  void toggleEditing() {
    state.maybeMap(
      loaded: (currentState) {
        emit(currentState.copyWith(isEditing: !currentState.isEditing));
      },
      orElse: () {},
    );
  }

  Future<dartz.Either<Exception, List<ProfileEntity>>> getConnections(
    String userId,
  ) async {
    return _profileRepository.getConnections(userId);
  }

  Future<void> requestConnection(String userId) async {
    final result = await _profileRepository.requestConnection(userId);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(userId),
    );
  }

  Future<void> cancelConnection(String userId) async {
    final result = await _profileRepository.cancelConnection(userId);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(userId),
    );
  }

  Future<void> acceptConnection(String userId) async {
    final result = await _profileRepository.acceptConnection(userId);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) =>
          loadProfile(), // Reload current user profile to update counts if needed
    );
  }

  Future<void> rejectConnection(String userId) async {
    final result = await _profileRepository.rejectConnection(userId);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(),
    );
  }

  Future<void> removeConnection(String userId) async {
    final result = await _profileRepository.removeConnection(userId);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(userId),
    );
  }

  Future<void> updateFoodPreferences(String preferences) async {
    final result = await _profileRepository.updateFoodPreferences(preferences);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(),
    );
  }

  Future<void> updateMedicalRestrictions(String restrictions) async {
    final result = await _profileRepository.updateMedicalRestrictions(
      restrictions,
    );
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(),
    );
  }

  Future<void> updateAccountData(Map<String, dynamic> data) async {
    final result = await _profileRepository.updateAccountData(data: data);
    result.fold(
      (error) => emit(ProfileState.error(error.toString())),
      (_) => loadProfile(),
    );
  }
}
