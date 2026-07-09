import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

@lazySingleton
class DocumentsCubit extends Cubit<DocumentsState> {
  final DocumentsRepository _repository;
  final ProfileRepository _profileRepository;
  final FeedRepository _feedRepository;
  final SupabaseClient _supabaseClient;

  RealtimeChannel? _documentsSubscription;

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

    if (isClosed) return;

    final documentsResult =
        results[0] as Either<Exception, List<DocumentEntity>>;
    final profileResult = results.length > 1
        ? results[1] as Either<Exception, ProfileEntity>?
        : null;
    final missionResult = results.length > 2
        ? results[2] as Either<Exception, MissionEntity?>
        : null;

    documentsResult.fold(
      (error) {
        if (isClosed) return;
        final msg = error.toString().replaceFirst('Exception: ', '');
        emit(DocumentsState.error(msg));
      },
      (documents) {
        if (isClosed) return;
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

  /// Subscribes to Realtime changes on the `documentos` table for the current
  /// user. Automatically reloads documents when a row is inserted, updated,
  /// or deleted (e.g. admin refuses a document). This keeps the "pending
  /// documents" banner and badges up to date without manual navigation.
  void listenToDocumentChanges() {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    // Avoid duplicate subscriptions
    _documentsSubscription?.unsubscribe();

    _documentsSubscription = _supabaseClient
        .channel('public:documentos:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'documentos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (kDebugMode) {
              debugPrint('[DocumentsCubit] Realtime: documentos changed. event=${payload.eventType}');
            }
            // Silently refresh — loadDocuments emits loading then loaded.
            loadDocuments();
          },
        )
        .subscribe((status, [error]) {
          if (kDebugMode) {
            debugPrint('[DocumentsCubit] Realtime subscription status=$status error=$error');
          }
        });
  }

  Future<void> uploadDocument({
    String? id,
    required DocumentType type,
    File? file,
    String? documentNumber,
    DateTime? expiryDate,
    String? documentName,
    String? visaCountry,
  }) async {
    final result = await _repository.uploadDocument(
      id: id,
      type: type,
      file: file,
      documentNumber: documentNumber,
      expiryDate: expiryDate,
      documentName: documentName,
      visaCountry: visaCountry,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        if (isClosed) return;
        final msg = error.toString().replaceFirst('Exception: ', '');
        emit(DocumentsState.error(msg));
      },
      (_) => loadDocuments(),
    );
  }

  void dismissAlert() {
    state.mapOrNull(
      loaded: (state) => emit(state.copyWith(isAlertDismissed: true)),
    );
  }

  Future<Either<Exception, Map<String, dynamic>>> parseDocument({
    required DocumentType type,
    required File file,
  }) async {
    return await _repository.parseDocument(
      type: type,
      file: file,
    );
  }

  void reset() {
    _documentsSubscription?.unsubscribe();
    _documentsSubscription = null;
    emit(const DocumentsState.initial());
  }

  @override
  Future<void> close() {
    _documentsSubscription?.unsubscribe();
    return super.close();
  }
}
