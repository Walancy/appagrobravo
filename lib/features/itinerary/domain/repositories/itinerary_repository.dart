import 'package:dartz/dartz.dart';
import '../entities/itinerary_item.dart';
import '../entities/itinerary_group.dart';
import '../entities/emergency_contacts.dart';
import '../entities/mission_material.dart';
import '../entities/checklist_item.dart';
import '../entities/form_field_entity.dart';
import 'package:agrobravo/features/onboarding/data/models/grupo_formulario_model.dart';

abstract class ItineraryRepository {
  Future<Either<Exception, ItineraryGroupEntity>> getGroupDetails(
    String groupId,
  );
  Future<Either<Exception, List<ItineraryItemEntity>>> getItinerary(
    String groupId,
  );
  Future<Either<Exception, List<Map<String, dynamic>>>> getTravelTimes(
    String groupId,
  );
  Future<Either<Exception, String?>> getUserGroupId();
  Future<Either<Exception, List<ItineraryGroupEntity>>> getActiveGroups();
  Future<Either<Exception, List<String>>> getUserPendingDocuments();
  Future<Either<Exception, List<MissionMaterialEntity>>> getMissionMaterials(
    String groupId,
  );
  Future<Either<Exception, EmergencyContacts>> getEmergencyContacts(
    double lat,
    double lng,
  );

  /// Returns all checklist items for the group, with isChecked set per current user.
  Future<Either<Exception, List<ChecklistItemEntity>>> getChecklist(
    String groupId,
  );

  /// Marks [itemId] as checked (insert) or unchecked (delete).
  Future<Either<Exception, void>> toggleChecklistItem(
    String itemId,
    bool isChecked,
  );

  /// Returns true if [groupId] has primeiraAcesso = true for the current user.
  Future<Either<Exception, bool>> checkPrimeiraAcesso(String groupId);

  // ── Form methods ──────────────────────────────────────────────────────────

  /// Returns all form fields for the given material, ordered by [ordem].
  Future<Either<Exception, List<FormFieldEntity>>> getFormFields(
    String materialId,
  );

  /// Returns the current user's responses for [materialId].
  /// Map key = campo_id, value = valor (string).
  Future<Either<Exception, Map<String, String?>>> getFormResponses(
    String materialId,
  );

  /// Saves (upsert) the user's responses.
  /// [responses] is a list of {campoId, valor}.
  Future<Either<Exception, void>> saveFormResponses(
    String materialId,
    List<Map<String, String?>> responses,
  );

  // ── GrupoFormulario methods (forms from admin panel) ─────────────────────

  /// Returns all visible, non-onboarding formularios for the group,
  /// with hasUserResponse set per current user.
  Future<Either<Exception, List<GrupoFormularioModel>>> getGrupoFormularios(
    String groupId,
  );

  /// Returns the current user's existing responses for [formularioId].
  /// Map key = pergunta_id, value = dynamic (String, bool, or List).
  Future<Either<Exception, Map<String, dynamic>>> getGrupoFormularioRespostas(
    String formularioId,
  );

  /// Saves the user's responses for a grupoFormulario.
  Future<Either<Exception, void>> saveGrupoFormularioRespostas(
    String formularioId,
    Map<String, dynamic> respostas,
  );
}

