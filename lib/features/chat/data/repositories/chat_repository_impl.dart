import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/chat/domain/entities/chat_entity.dart';
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrobravo/features/chat/domain/entities/message_entity.dart';

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

      var groupsResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id')
          .eq('user_id', userId);

      if ((groupsResponse as List).isEmpty && userEmail != null) {
        try {
          final groupsByEmail = await _supabaseClient
              .from('gruposParticipantes')
              .select('grupo_id')
              .eq('email', userEmail);

          if ((groupsByEmail as List).isNotEmpty) {
            groupsResponse = groupsByEmail;
          }
        } catch (_) {}
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
          .select('id, missao_id, nome, data_inicio, data_fim, logo')
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
            .select('id, nome, logo')
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
        final String? logo = g['logo'] ?? missionData?['logo'];

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
            id: groupId,
            title: groupName,
            subtitle: missionName,
            imageUrl: logo,
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
              .select('id, nome, foto')
              .inFilter('id', leaderIds);

          for (var u in usersResponse as List) {
            guides.add(
              GuideEntity(
                id: u['id'],
                name: u['nome'] ?? 'Guia',
                role: 'Guia',
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

  @override
  Stream<List<MessageEntity>> getMessages(
    String chatId, {
    bool isGroup = true,
  }) async* {
    try {
      final realChatId = await _resolveChatId(chatId, isGroup);
      if (realChatId == null) {
        yield [];
        return;
      }

      yield* _supabaseClient
          .from('mensagens')
          .stream(primaryKey: ['id'])
          .eq('batepapo_id', realChatId)
          .order('created_at', ascending: true)
          .asyncMap((data) async {
            final messages = <MessageEntity>[];
            final currentUser = _supabaseClient.auth.currentUser;

            // Collect unique user IDs from messages to fetch them in batch (optimization)
            final userIds = data.map((e) => e['user_id'] as String).toSet();
            Map<String, Map<String, dynamic>> userMap = {};

            if (userIds.isNotEmpty) {
              try {
                final usersResponse = await _supabaseClient
                    .from('users')
                    .select('id, nome, foto, cargo')
                    .inFilter('id', userIds.toList());

                for (var u in usersResponse as List) {
                  userMap[u['id']] = u as Map<String, dynamic>;
                }
              } catch (e) {
                print('Error fetching users for messages: $e');
                print(StackTrace.current);
                // Continue with empty userMap - messages will show without user details
              }
            }

            for (final msg in data) {
              final userId = msg['user_id'] as String;
              final userData = userMap[userId];

              final isMe = currentUser?.id == userId;
              final role = userData?['cargo'] as String?;
              final isGuide = role?.toLowerCase().contains('guia') ?? false;

              MessageType type = isMe
                  ? MessageType.me
                  : (isGuide ? MessageType.guide : MessageType.other);

              messages.add(
                MessageEntity(
                  id: msg['id'],
                  text: msg['mensagem'] ?? '',
                  timestamp: DateTime.parse(msg['created_at']),
                  type: type,
                  userName: userData?['nome'],
                  userAvatarUrl: userData?['foto'],
                  guideRole: role,
                  attachmentUrl: msg['imagem'],
                  repliedToMessage: msg['id_mensagem_respondida'] != null
                      ? messages.firstWhere(
                          (m) => m.id == msg['id_mensagem_respondida'],
                          orElse: () =>
                              // Return a dummy entity or null. Since orElse expects MessageEntity (non-nullable return for firstWhere unless collection is nullable but here it's List<MessageEntity>),
                              // actually firstWhere(..., orElse: () => null) is valid ONLY if the return type is nullable.
                              // But List.firstWhere returns E, not E?.
                              // Given the error "type 'Null' is not a subtype of type 'MessageEntity'", it means orElse returned null but firstWhere expects MessageEntity.
                              // We should change how we find the message.
                              MessageEntity(
                                id: 'deleted',
                                text: 'Mensagem não encontrada',
                                timestamp: DateTime.fromMicrosecondsSinceEpoch(
                                  0,
                                ),
                                type: MessageType.other,
                                isEdited: false,
                                isDeleted: true,
                              ),
                        )
                      : null,
                  isEdited: msg['editado'] ?? false,
                  isDeleted: msg['deletado'] ?? false,
                ),
              );
            }
            return messages;
          });
    } catch (e) {
      print('Error in stream: $e');
      print(StackTrace.current);
      yield [];
    }
  }

  @override
  Future<void> editMessage(String messageId, String newText) async {
    await _supabaseClient
        .from('mensagens')
        .update({
          'mensagem': newText,
          'editado': true,
          'editado_em': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId);
  }

  @override
  Future<void> deleteMessages(List<String> messageIds) async {
    await _supabaseClient
        .from('mensagens')
        .update({'deletado': true})
        .inFilter('id', messageIds);
  }

  @override
  Future<void> sendMessage(
    String chatId,
    String text, {
    bool isGroup = true,
    XFile? image,
    String? replyToId,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final realChatId = await _resolveChatId(chatId, isGroup);
    if (realChatId == null) throw Exception('Could not resolve chat ID');

    String? imageUrl;
    if (image != null) {
      final bytes = await image.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = image.path.split('.').last;
      final fileName = '${timestamp}_chat_image.$ext';
      final storagePath = 'chats/$realChatId/$fileName';

      await _supabaseClient.storage
          .from('files')
          .uploadBinary(storagePath, bytes);
      imageUrl = _supabaseClient.storage
          .from('files')
          .getPublicUrl(storagePath);
    }

    await _supabaseClient.from('mensagens').insert({
      'batepapo_id': realChatId,
      'user_id': user.id,
      'mensagem': text,
      'imagem': imageUrl,
      'id_mensagem_respondida': replyToId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Either<Exception, GroupDetailEntity>> getGroupDetails(
    String groupId,
  ) async {
    try {
      // 1. Resolve batepapo_id for media
      final batePapoId = await _resolveChatId(groupId, true);

      // 2. Fetch Media
      List<String> mediaUrls = [];
      if (batePapoId != null) {
        final messagesResponse = await _supabaseClient
            .from('mensagens')
            .select('imagem')
            .eq('batepapo_id', batePapoId)
            .not('imagem', 'is', null)
            .order('created_at', ascending: false);

        mediaUrls = (messagesResponse as List)
            .map((m) => m['imagem'] as String)
            .toList();
      }

      // 3. Fetch Participants (Normal Users)
      final participantsResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('user_id')
          .eq('grupo_id', groupId);

      final participantUserIds = (participantsResponse as List)
          .map((p) => p['user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      // 4. Fetch Leaders (Guides)
      final leadersResponse = await _supabaseClient
          .from('lideresGrupo')
          .select('lider_id')
          .eq('grupo_id', groupId);

      final leaderIds = (leadersResponse as List)
          .map((l) => l['lider_id'] as String)
          .toSet();

      final allUserIds = {...participantUserIds, ...leaderIds};
      final currentUserId = _supabaseClient.auth.currentUser?.id;

      List<GroupMemberEntity> members = [];
      if (allUserIds.isNotEmpty) {
        final usersResponse = await _supabaseClient
            .from('users')
            .select('id, nome, foto, cargo')
            .inFilter('id', allUserIds.toList());

        // Fetch connection statuses relative to current user
        Map<String, ConnectionStatus> statuses = {};
        if (currentUserId != null) {
          final connectionsResponse = await _supabaseClient
              .from('conexoes')
              .select('*')
              .or(
                'and(seguidor_id.eq.$currentUserId,seguido_id.in.(${allUserIds.join(",")})),and(seguido_id.eq.$currentUserId,seguidor_id.in.(${allUserIds.join(",")}))',
              );

          for (final c in connectionsResponse as List) {
            final seguidorId = c['seguidor_id'];
            final seguidoId = c['seguido_id'];
            final aprovou = c['aprovou'] as bool;

            final otherId = seguidorId == currentUserId
                ? seguidoId
                : seguidorId;

            if (aprovou) {
              statuses[otherId] = ConnectionStatus.connected;
            } else {
              if (seguidorId == currentUserId) {
                statuses[otherId] = ConnectionStatus.pendingSent;
              } else {
                statuses[otherId] = ConnectionStatus.pendingReceived;
              }
            }
          }
        }

        for (var u in usersResponse as List) {
          final id = u['id'] as String;
          final isGuide = leaderIds.contains(id);
          final isMe = id == currentUserId;

          members.add(
            GroupMemberEntity(
              id: id,
              name: u['nome'] ?? 'Membro',
              role: u['cargo'] ?? (isGuide ? 'Guia' : 'Produtor'),
              isGuide: isGuide,
              isMe: isMe,
              avatarUrl: u['foto'],
              connectionStatus: statuses[id] ?? ConnectionStatus.none,
            ),
          );
        }
      }

      // Sort members: Current User first, then Guides, then by name
      members.sort((a, b) {
        if (a.isMe && !b.isMe) return -1;
        if (!a.isMe && b.isMe) return 1;
        if (a.isGuide && !b.isGuide) return -1;
        if (!a.isGuide && b.isGuide) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return Right(GroupDetailEntity(members: members, mediaUrls: mediaUrls));
    } catch (e) {
      return Left(Exception('Erro ao carregar detalhes do grupo: $e'));
    }
  }

  Future<String?> _resolveChatId(String identifier, bool isGroup) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    if (isGroup) {
      // identifier is group_id
      try {
        final response = await _supabaseClient
            .from('batePapo')
            .select('id')
            .eq('grupo_id', identifier)
            .maybeSingle();

        if (response != null) {
          return response['id'] as String;
        } else {
          // Create if not exists
          final newChat = await _supabaseClient
              .from('batePapo')
              .insert({'grupo_id': identifier})
              .select('id')
              .single();
          return newChat['id'] as String;
        }
      } catch (e) {
        // Handle creation error (e.g. race condition/duplicate), default to search again
        final response = await _supabaseClient
            .from('batePapo')
            .select('id')
            .eq('grupo_id', identifier)
            .maybeSingle();
        return response?['id'] as String?;
      }
    } else {
      // identifier is other user_id (Leader/Guide)
      try {
        final response = await _supabaseClient
            .from('batePapo')
            .select('id')
            .or(
              'and(lider_id.eq.$identifier,user_id.eq.$userId),and(lider_id.eq.$userId,user_id.eq.$identifier)',
            )
            .maybeSingle();

        if (response != null) {
          return response['id'] as String;
        } else {
          final newChat = await _supabaseClient
              .from('batePapo')
              .insert({'lider_id': identifier, 'user_id': userId})
              .select('id')
              .single();
          return newChat['id'] as String;
        }
      } catch (e) {
        final response = await _supabaseClient
            .from('batePapo')
            .select('id')
            .or(
              'and(lider_id.eq.$identifier,user_id.eq.$userId),and(lider_id.eq.$userId,user_id.eq.$identifier)',
            )
            .maybeSingle();
        return response?['id'] as String?;
      }
    }
  }
}
