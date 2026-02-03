import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabaseClient;

  ChatRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, ChatData>> getChatData() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado.'));

      // 1. Fetch User's Groups
      final userEmail = _supabaseClient.auth.currentUser?.email;

      // 1. Fetch User's Groups (try by user_id OR email to be safe)
      // Since we can't do robust OR across columns easily without custom RPC or exact syntax,
      // and typically we look up by user_id.
      // If RLS allows, we can try to find by email if user_id fails.
      // But let's try to query by user_id first.

      var groupsResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id')
          .eq('user_id', userId);

      // Fallback: Check by email if list is empty and email is available
      if ((groupsResponse as List).isEmpty && userEmail != null) {
        try {
          final groupsByEmail = await _supabaseClient
              .from('gruposParticipantes')
              .select('grupo_id')
              .eq('email', userEmail);

          if ((groupsByEmail as List).isNotEmpty) {
            groupsResponse = groupsByEmail;
          }
        } catch (_) {
          // Ignore error if column email doesn't exist or permission denied
        }
      }

      final groupIds = (groupsResponse as List)
          .map((e) => e['grupo_id'] as String?)
          .where((e) => e != null)
          .cast<String>()
          .toList();

      if (groupIds.isEmpty) {
        return const Right(ChatData());
      }

      // 2. Fetch Missions linked to these Groups
      final groupsDetailsResponse = await _supabaseClient
          .from('grupos')
          .select(
            'id, missao_id, nome, data_inicio, data_fim',
          ) // Added date columns
          .inFilter('id', groupIds);

      final missionIds = <String>{};

      for (var g in groupsDetailsResponse as List) {
        final mId = g['missao_id'] as String?;
        if (mId != null) {
          missionIds.add(mId);
        }
      }

      // 3. Fetch Mission Details (logo, name) if missions exist
      Map<String, dynamic> missionMap = {};

      if (missionIds.isNotEmpty) {
        final missionsResponse = await _supabaseClient
            .from('missoes')
            .select(
              'id, nome, logo',
            ) // Removed dates from here as we use Group dates mostly
            .inFilter('id', missionIds.toList());

        missionMap = {
          for (var m in missionsResponse as List) m['id'] as String: m,
        };
      }

      List<ChatEntity> allChats = [];

      // Iterate over Groups to create Chat Entities
      for (var g in groupsDetailsResponse as List) {
        final groupId = g['id'] as String;
        final groupName = g['nome'] as String? ?? 'Grupo sem nome';
        final missionId = g['missao_id'] as String?;

        final missionData = missionId != null ? missionMap[missionId] : null;

        final String missionName = missionData?['nome'] ?? '';
        final String? logo = missionData?['logo'];

        DateTime? start;
        DateTime? end;

        // Priority: Group Dates -> Mission Dates (fallback)
        if (g['data_inicio'] != null) {
          start = DateTime.tryParse(g['data_inicio']);
        } else if (missionData != null && missionData['data_inicio'] != null) {
          start = DateTime.tryParse(missionData['data_inicio']);
        }

        if (g['data_fim'] != null) {
          end = DateTime.tryParse(g['data_fim']);
        } else if (missionData != null && missionData['data_fim'] != null) {
          end = DateTime.tryParse(missionData['data_fim']);
        }

        allChats.add(
          ChatEntity(
            id: groupId, // ID TO CHAT IS GROUP ID
            title: groupName,
            subtitle: missionName,
            imageUrl: logo, // Logo typically comes from mission
            startDate: start,
            endDate: end,
            memberCount: 0,
          ),
        );
      }

      // 4. Determine Current vs History
      final now = DateTime.now();
      ChatEntity? current;
      List<ChatEntity> history = [];

      // Sort by date (descending)
      allChats.sort((a, b) {
        final aDate = a.endDate ?? DateTime(2000);
        final bDate = b.endDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      for (var chat in allChats) {
        if (chat.endDate != null && chat.endDate!.isAfter(now)) {
          if (current == null) {
            current = chat;
          } else {
            history.add(chat);
          }
        } else {
          history.add(chat);
        }
      }

      // 5. Fetch Guides for the Current Mission GROUP
      List<GuideEntity> guides = [];
      if (current != null) {
        final currentGroupId = current.id;

        // Fetch leaders/guides from lideresGrupo table
        final leadersResponse = await _supabaseClient
            .from('lideresGrupo')
            .select('lider_id')
            .eq('grupo_id', currentGroupId);

        final leaderIds = (leadersResponse as List)
            .map((l) => l['lider_id'] as String)
            .toSet()
            .toList();

        if (leaderIds.isNotEmpty) {
          final usersResponse = await _supabaseClient
              .from('users')
              .select(
                'id, nome, foto',
              ) // Don't strictly need roles if they are in leaders table? Maybe fetch to show subtitle.
              .inFilter('id', leaderIds);

          for (var u in usersResponse as List) {
            // If they are in lideresGrupo, they are guides/leaders for this group.
            // We can hardcode role as 'Guia' or 'Líder', or fetch tipouser if needed.
            // Let's use 'Guia' as default.

            guides.add(
              GuideEntity(
                id: u['id'],
                name: u['nome'] ?? 'Guia',
                role: 'Guia', // Default role since they are in leaders table
                avatarUrl: u['foto'],
              ),
            );
          }
        }
      }

      return Right(
        ChatData(currentMission: current, guides: guides, history: history),
      );
    } catch (e) {
      return Left(Exception('Erro ao carregar chat: $e'));
    }
  }
}
