import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileCubit(this._profileRepository, this._authRepository)
    : super(const ProfileState.initial());

  String _mapFailure(Object failure) {
    final message = failure.toString();
    if (message.contains('SocketException') ||
        message.contains('ClientException') ||
        message.contains('Network is unreachable') ||
        message.contains('Failed host lookup')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    }
    return message.replaceAll('Exception: ', '');
  }

  Future<void> loadProfile([String? userId]) async {
    emit(const ProfileState.loading());

    try {
      String? targetUserId = userId;
      bool isMe = false;

      if (targetUserId == null) {
        final userOption = await _authRepository.getCurrentUser();
        if (isClosed) return;
        targetUserId = userOption.fold(() => null, (user) => user.id);
        isMe = true;
      } else {
        final userOption = await _authRepository.getCurrentUser();
        if (isClosed) return;
        final currentId = userOption.fold(() => null, (user) => user.id);
        isMe = targetUserId == currentId;
      }

      if (targetUserId == null) {
        if (isClosed) return;
        emit(const ProfileState.error('Usuário não autenticado'));
        return;
      }

      final profileResult = await _profileRepository.getProfile(targetUserId);
      if (isClosed) return;
      final postsResult = await _profileRepository.getUserPosts(targetUserId);
      if (isClosed) return;

      profileResult.fold(
        (error) {
          if (isClosed) return;
          emit(ProfileState.error(_mapFailure(error)));
        },
        (profile) {
          postsResult.fold(
            (error) {
              if (isClosed) return;
              emit(ProfileState.error(_mapFailure(error)));
            },
            (posts) {
              if (isClosed) return;
              emit(
                ProfileState.loaded(profile: profile, posts: posts, isMe: isMe),
              );
            },
          );
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProfileState.error('Erro ao carregar perfil: ${_mapFailure(e)}'));
    }
  }

  /// Extensão do arquivo para o storage. `XFile.fromData` tem `path` vazio,
  /// então usa o `name` como fonte e cai para 'png' se não houver extensão.
  String _fileExtension(XFile file) {
    final source = file.path.isNotEmpty ? file.path : file.name;
    final dotIndex = source.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == source.length - 1) return 'png';
    return source.substring(dotIndex + 1);
  }

  Future<void> updateProfilePhoto(XFile file) async {
    state.maybeMap(
      loaded: (currentState) async {
        final bytes = await file.readAsBytes();
        final extension = _fileExtension(file);
        final result = await _profileRepository.updateProfilePhoto(
          bytes,
          extension,
        );

        if (isClosed) return;

        result.fold((error) {
          if (isClosed) return;
          emit(ProfileState.error(_mapFailure(error)));
        }, (
          newUrl,
        ) {
          if (isClosed) return;
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
        final extension = _fileExtension(file);
        final result = await _profileRepository.updateCoverPhoto(
          bytes,
          extension,
        );

        if (isClosed) return;

        result.fold((error) {
          if (isClosed) return;
          emit(ProfileState.error(_mapFailure(error)));
        }, (
          newUrl,
        ) {
          if (isClosed) return;
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

  /// Envia ao servidor as imagens selecionadas (bytes) e desliga o modo de
  /// edição. Só é chamado quando o usuário toca em "Salvar" — antes disso as
  /// imagens ficam apenas como preview local na tela.
  Future<void> savePhotos({
    Uint8List? avatarBytes,
    Uint8List? coverBytes,
  }) async {
    if (avatarBytes != null) {
      final result = await _profileRepository.updateProfilePhoto(
        avatarBytes,
        'png',
      );
      if (isClosed) return;
      var failed = false;
      result.fold(
        (error) {
          failed = true;
          emit(ProfileState.error(_mapFailure(error)));
        },
        (newUrl) {
          state.maybeMap(
            loaded: (s) => emit(
              s.copyWith(profile: s.profile.copyWith(avatarUrl: newUrl)),
            ),
            orElse: () {},
          );
        },
      );
      if (failed) return;
    }

    if (coverBytes != null) {
      final result = await _profileRepository.updateCoverPhoto(
        coverBytes,
        'png',
      );
      if (isClosed) return;
      var failed = false;
      result.fold(
        (error) {
          failed = true;
          emit(ProfileState.error(_mapFailure(error)));
        },
        (newUrl) {
          state.maybeMap(
            loaded: (s) => emit(
              s.copyWith(profile: s.profile.copyWith(coverUrl: newUrl)),
            ),
            orElse: () {},
          );
        },
      );
      if (failed) return;
    }

    // Desliga o modo edição após salvar tudo com sucesso.
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(isEditing: false)),
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
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(userId),
    );
  }

  Future<void> cancelConnection(String userId) async {
    final result = await _profileRepository.cancelConnection(userId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(userId),
    );
  }

  Future<void> acceptConnection(String userId) async {
    final result = await _profileRepository.acceptConnection(userId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) =>
          loadProfile(), // Reload current user profile to update counts if needed
    );
  }

  Future<void> rejectConnection(String userId) async {
    final result = await _profileRepository.rejectConnection(userId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(),
    );
  }

  Future<void> removeConnection(String userId) async {
    final result = await _profileRepository.removeConnection(userId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(userId),
    );
  }

  Future<void> updateFoodPreferences(List<String> preferences) async {
    final result = await _profileRepository.updateFoodPreferences(preferences);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(),
    );
  }

  Future<void> updateMedicalRestrictions(List<String> restrictions) async {
    final result = await _profileRepository.updateMedicalRestrictions(
      restrictions,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(),
    );
  }

  Future<void> updateAccountData(Map<String, dynamic> data) async {
    final result = await _profileRepository.updateAccountData(data: data);
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) => loadProfile(),
    );
  }

  Future<void> updateNotificationPreferences(Map<String, bool> prefs) async {
    final result = await _profileRepository.updateNotificationPreferences(
      prefs,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        if (isClosed) return;
        emit(ProfileState.error(_mapFailure(error)));
      },
      (_) =>
          null, // Don't reload whole profile, just local save. Or reload if needed.
    );
  }

  Future<Map<String, bool>> getNotificationPreferences() async {
    final result = await _profileRepository.getNotificationPreferences();
    return result.fold((_) => {}, (prefs) => prefs);
  }

  void reset() {
    emit(const ProfileState.initial());
  }
}
