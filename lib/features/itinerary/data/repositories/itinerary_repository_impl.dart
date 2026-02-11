import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../../domain/entities/itinerary_group.dart';
import '../../domain/entities/itinerary_item.dart';
import '../models/itinerary_group_dto.dart';
import '../models/itinerary_item_dto.dart';

@LazySingleton(as: ItineraryRepository)
class ItineraryRepositoryImpl implements ItineraryRepository {
  final SupabaseClient _supabaseClient;

  ItineraryRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, ItineraryGroupEntity>> getGroupDetails(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('grupos')
          .select()
          .eq('id', groupId)
          .single();

      return Right(ItineraryGroupDto.fromJson(response).toEntity());
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<ItineraryItemEntity>>> getItinerary(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('eventos')
          .select()
          .eq('grupo_id', groupId)
          .order('data')
          .order('hora_inicio');

      final List<dynamic> data = response as List<dynamic>;
      final items = data
          .map((json) => ItineraryItemDto.fromJson(json).toEntity())
          .toList();

      return Right(items);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Map<String, dynamic>>>> getTravelTimes(
    String groupId,
  ) async {
    try {
      final response = await _supabaseClient.rpc(
        'buscar_itinerario_grupo_deslocamento',
        params: {'p_grupo_id': groupId},
      );

      final List<dynamic> data = response as List<dynamic>;
      return Right(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return Left(Exception('Erro ao buscar tempos de deslocamento: $e'));
    }
  }

  @override
  Future<Either<Exception, String?>> getUserGroupId() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final response = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id')
          .eq('user_id', userId)
          .maybeSingle(); // Assumes user belongs to one main group for now, or takes the first one found

      if (response == null) return const Right(null);

      return Right(response['grupo_id'] as String?);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
