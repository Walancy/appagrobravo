import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../home/domain/repositories/feed_repository.dart';
import '../../../home/domain/entities/mission_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';
import '../../domain/repositories/documents_repository.dart';
import 'documents_state.dart';

@injectable
class DocumentsCubit extends Cubit<DocumentsState> {
  final DocumentsRepository _repository;
  final ProfileRepository _profileRepository;
  final FeedRepository _feedRepository;
  final SupabaseClient _supabaseClient;

  DocumentsCubit(
    this._repository,
    this._profileRepository,
    this._feedRepository,
    this._supabaseClient,
  ) : super(const DocumentsState.initial());

  Future<void> loadDocuments() async {
    emit(const DocumentsState.loading());
    final userId = _supabaseClient.auth.currentUser?.id;

    final results = await Future.wait([
      _repository.getDocuments(),
      if (userId != null)
        _profileRepository.getProfile(userId)
      else
        Future.value(null),
      _feedRepository.getLatestMissionAlert(),
    ]);

    final documentsResult =
        results[0] as Either<Exception, List<DocumentEntity>>;
    final profileResult = results.length > 1
        ? results[1] as Either<Exception, ProfileEntity>?
        : null;
    final missionResult = results.length > 2
        ? results[2] as Either<Exception, MissionEntity?>
        : null;

    documentsResult.fold(
      (error) => emit(DocumentsState.error(error.toString())),
      (documents) {
        // fallback to null if error in profile
        final safeProfile = profileResult?.fold((_) => null, (p) => p);
        final safeMission = missionResult?.fold((_) => null, (m) => m);
        emit(
          DocumentsState.loaded(
            documents,
            profile: safeProfile,
            mission: safeMission,
          ),
        );
      },
    );
  }

  Future<void> uploadDocument({
    required DocumentType type,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    final result = await _repository.uploadDocument(
      type: type,
      file: file,
      documentNumber: documentNumber,
      expiryDate: expiryDate,
    );

    result.fold(
      (error) => emit(DocumentsState.error(error.toString())),
      (_) => loadDocuments(),
    );
  }

  void dismissAlert() {
    state.mapOrNull(
      loaded: (state) => emit(state.copyWith(isAlertDismissed: true)),
    );
  }
}
