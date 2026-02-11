import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/data/models/post_model.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, ProfileEntity>> getProfile(String userId) async {
    try {
      final userResponse = await _supabaseClient
          .from('users')
          .select(
            'id, nome, foto, cargo, observacoes, capa_perfil, email, telefone, restricoes_alimentares, restricoes_medicas',
          )
          .eq('id', userId)
          .single();

      // 2. Fetch Posts Count
      final postsResponse = await _supabaseClient
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      final postsCount = (postsResponse as List).length;

      // 3. Fetch Missions Count
      final missionsResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('id')
          .eq('user_id', userId);

      final missionsCount = (missionsResponse as List).length;

      // 4. Fetch Connections Count
      final connectionsResponse = await _supabaseClient
          .from('conexoes')
          .select('aprovou')
          .or('seguidor_id.eq.$userId,seguido_id.eq.$userId')
          .eq('aprovou', true);

      final connectionsCount = (connectionsResponse as List).length;

      // 5. Fetch Connection Status relative to current user
      ConnectionStatus connectionStatus = ConnectionStatus.none;
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId != null && currentUserId != userId) {
        final statusRes = await _supabaseClient
            .from('conexoes')
            .select('*')
            .or(
              'and(seguidor_id.eq.$currentUserId,seguido_id.eq.$userId),and(seguido_id.eq.$currentUserId,seguidor_id.eq.$userId)',
            )
            .maybeSingle();

        if (statusRes != null) {
          final isAprovou = statusRes['aprovou'] as bool;
          if (isAprovou) {
            connectionStatus = ConnectionStatus.connected;
          } else {
            if (statusRes['seguidor_id'] == currentUserId) {
              connectionStatus = ConnectionStatus.pendingSent;
            } else {
              connectionStatus = ConnectionStatus.pendingReceived;
            }
          }
        }
      }

      // 6. Fetch Current Mission and Group
      String? missionName;
      String? groupName;

      try {
        final missionRes = await _supabaseClient
            .from('gruposParticipantes')
            .select('grupos:grupo_id (nome, missoes:missao_id (nome))')
            .eq('user_id', userId)
            .limit(1)
            .maybeSingle();

        if (missionRes != null && missionRes['grupos'] != null) {
          final g = missionRes['grupos'];
          if (g is Map) {
            groupName = g['nome'];
            final m = g['missoes'];
            if (m is Map) {
              missionName = m['nome'];
            } else if (m is List && m.isNotEmpty) {
              missionName = m.first['nome'];
            }
          }
        }
      } catch (_) {}

      return Right(
        ProfileEntity(
          id: userResponse['id'],
          name: userResponse['nome'] ?? 'Sem nome',
          avatarUrl: userResponse['foto'],
          coverUrl: userResponse['capa_perfil'],
          jobTitle: userResponse['cargo'],
          bio: userResponse['observacoes'],
          missionName: missionName,
          groupName: groupName,
          email: userResponse['email'],
          phone: userResponse['telefone'],
          cpf: userResponse['cpf'],
          ssn: userResponse['ssn'],
          company: userResponse['empresa'],
          zipCode: userResponse['cep'],
          state: userResponse['estado'],
          city: userResponse['cidade'],
          street: userResponse['rua'],
          number: userResponse['numero'],
          neighborhood: userResponse['bairro'],
          complement: userResponse['complemento'],
          birthDate: userResponse['datanascimento'] != null
              ? DateTime.tryParse(userResponse['datanascimento'])
              : (userResponse['data_nascimento'] != null
                    ? DateTime.tryParse(userResponse['data_nascimento'])
                    : null),
          nationality: userResponse['nacionalidade'],
          passport: userResponse['n_passaporte'],
          foodPreferences: (userResponse['restricoes_alimentares'] as List?)
              ?.cast<String>(),
          medicalRestrictions: (userResponse['restricoes_medicas'] as List?)
              ?.cast<String>(),
          connectionsCount: connectionsCount,
          postsCount: postsCount,
          missionsCount: missionsCount,
          connectionStatus: connectionStatus,
        ),
      );
    } catch (e) {
      return Left(Exception('Erro ao buscar perfil: $e'));
    }
  }

  @override
  Future<Either<Exception, List<PostEntity>>> getUserPosts(
    String userId,
  ) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      final response = await _supabaseClient
          .from('posts')
          .select('''
            *,
            users:user_id (nome, foto),
            missoes:missao_id (nome),
            curtidas:curtidas(user_id),
            comentarios:comentarios(id)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts = (response as List).map((postMap) {
        final post = PostModel.fromJson(postMap);
        final user = postMap['users'] as Map<String, dynamic>?;
        final missao = postMap['missoes'] as Map<String, dynamic>?;

        final curtidasList = postMap['curtidas'] as List?;
        final commentsList = postMap['comentarios'] as List?;

        final likesCount = curtidasList?.length ?? 0;
        final commentsCount = commentsList?.length ?? 0;

        final isLiked =
            currentUserId != null &&
            curtidasList != null &&
            curtidasList.any((c) => c['user_id'] == currentUserId);

        return post.toEntity().copyWith(
          userName: user?['nome'] ?? 'Usuário',
          userAvatar: user?['foto'],
          missionName: missao?['nome'],
          likesCount: likesCount,
          commentsCount: commentsCount,
          isLiked: isLiked,
        );
      }).toList();

      return Right(posts);
    } catch (e) {
      return Left(Exception('Erro ao buscar posts do usuário: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> updateProfilePhoto(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final userId = _supabaseClient.auth.currentUser!.id;
      final path = 'avatars/$userId/$fileName';

      await _supabaseClient.storage.from('app').upload(path, file);

      final url = _supabaseClient.storage.from('app').getPublicUrl(path);

      await _supabaseClient
          .from('users')
          .update({'foto': url})
          .eq('id', userId);

      return Right(url);
    } catch (e) {
      return Left(Exception('Erro ao atualizar foto: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> updateCoverPhoto(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_cover.jpg';
      final userId = _supabaseClient.auth.currentUser!.id;
      final path = 'covers/$userId/$fileName';

      await _supabaseClient.storage.from('app').upload(path, file);

      final url = _supabaseClient.storage.from('app').getPublicUrl(path);

      await _supabaseClient
          .from('users')
          .update({'capa_perfil': url})
          .eq('id', userId);

      return Right(url);
    } catch (e) {
      return Left(Exception('Erro ao atualizar capa: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ProfileEntity>>> getConnections(
    String userId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('conexoes')
          .select('seguidor_id, seguido_id')
          .or('seguidor_id.eq.$userId,seguido_id.eq.$userId')
          .eq('aprovou', true);

      final connectionIds = (response as List)
          .expand((c) {
            return [c['seguidor_id'], c['seguido_id']];
          })
          .where((id) => id != userId)
          .toSet()
          .toList();

      if (connectionIds.isEmpty) return const Right([]);

      return _fetchProfiles(connectionIds);
    } catch (e) {
      return Left(Exception('Erro ao buscar conexões: $e'));
    }
  }

  @override
  Future<Either<Exception, List<ProfileEntity>>> getRequests(
    String userId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('conexoes')
          .select('seguidor_id')
          .eq('seguido_id', userId)
          .eq('aprovou', false);

      final requestIds = (response as List)
          .map((c) => c['seguidor_id'])
          .toList();

      if (requestIds.isEmpty) return const Right([]);

      return _fetchProfiles(requestIds);
    } catch (e) {
      return Left(Exception('Erro ao buscar solicitações: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> requestConnection(String userId) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;
      await _supabaseClient.from('conexoes').insert({
        'seguidor_id': currentUserId,
        'seguido_id': userId,
        'aprovou': false,
      });
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao solicitar conexão: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> cancelConnection(String userId) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;
      await _supabaseClient
          .from('conexoes')
          .delete()
          .eq('seguidor_id', currentUserId)
          .eq('seguido_id', userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao cancelar solicitação: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> acceptConnection(String userId) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;
      await _supabaseClient
          .from('conexoes')
          .update({'aprovou': true})
          .eq('seguidor_id', userId)
          .eq('seguido_id', currentUserId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao aceitar conexão: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> rejectConnection(String userId) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;
      await _supabaseClient
          .from('conexoes')
          .delete()
          .eq('seguidor_id', userId)
          .eq('seguido_id', currentUserId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao rejeitar conexão: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> removeConnection(String userId) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;
      await _supabaseClient
          .from('conexoes')
          .delete()
          .or(
            'and(seguidor_id.eq.$currentUserId,seguido_id.eq.$userId),and(seguidor_id.eq.$userId,seguido_id.eq.$currentUserId)',
          );
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao remover conexão: $e'));
    }
  }

  Future<Either<Exception, List<ProfileEntity>>> _fetchProfiles(
    List<dynamic> userIds,
  ) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      final usersResponse = await _supabaseClient
          .from('users')
          .select(
            'id, nome, foto, cargo, empresa, capa_perfil, observacoes, email, telefone, cpf, ssn, cep, estado, cidade, rua, numero, bairro, complemento, datanascimento, data_nascimento, nacionalidade, n_passaporte, restricoes_alimentares, restricoes_medicas',
          )
          .inFilter('id', userIds);

      // Fetch statuses relative to current user for these profiles
      Map<String, ConnectionStatus> statuses = {};
      if (currentUserId != null) {
        final connectionsResponse = await _supabaseClient
            .from('conexoes')
            .select('*')
            .or(
              'and(seguidor_id.eq.$currentUserId,seguido_id.in.(${userIds.join(",")})),and(seguido_id.eq.$currentUserId,seguidor_id.in.(${userIds.join(",")}))',
            );

        for (final c in connectionsResponse as List) {
          final seguidorId = c['seguidor_id'];
          final seguidoId = c['seguido_id'];
          final aprovou = c['aprovou'] as bool;

          if (aprovou) {
            statuses[seguidorId == currentUserId ? seguidoId : seguidorId] =
                ConnectionStatus.connected;
          } else {
            if (seguidorId == currentUserId) {
              statuses[seguidoId] = ConnectionStatus.pendingSent;
            } else {
              statuses[seguidorId] = ConnectionStatus.pendingReceived;
            }
          }
        }
      }

      final profiles = (usersResponse as List).map((u) {
        return ProfileEntity(
          id: u['id'],
          name: u['nome'] ?? 'Sem nome',
          avatarUrl: u['foto'],
          coverUrl: u['capa_perfil'],
          jobTitle: u['cargo'],
          company: u['empresa'],
          bio: u['observacoes'],
          missionName: null,
          groupName: null,
          email: u['email'],
          phone: u['telefone'],
          cpf: u['cpf'],
          ssn: u['ssn'],
          zipCode: u['cep'],
          state: u['estado'],
          city: u['cidade'],
          street: u['rua'],
          number: u['numero'],
          neighborhood: u['bairro'],
          complement: u['complemento'],
          birthDate: u['datanascimento'] != null
              ? DateTime.tryParse(u['datanascimento'])
              : (u['data_nascimento'] != null
                    ? DateTime.tryParse(u['data_nascimento'])
                    : null),
          nationality: u['nacionalidade'],
          passport: u['n_passaporte'],
          foodPreferences: (u['restricoes_alimentares'] as List?)
              ?.cast<String>(),
          medicalRestrictions: (u['restricoes_medicas'] as List?)
              ?.cast<String>(),
          connectionsCount: 0,
          postsCount: 0,
          missionsCount: 0,
          connectionStatus: statuses[u['id']] ?? ConnectionStatus.none,
        );
      }).toList();

      return Right(profiles);
    } catch (e) {
      return Left(Exception('Erro ao buscar informações dos usuários: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateFoodPreferences(
    String preferences,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;
      final list = preferences
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await _supabaseClient
          .from('users')
          .update({'restricoes_alimentares': list})
          .eq('id', userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao atualizar preferências alimentares: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateMedicalRestrictions(
    String restrictions,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;
      final list = restrictions
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await _supabaseClient
          .from('users')
          .update({'restricoes_medicas': list})
          .eq('id', userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao atualizar restrições médicas: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateAccountData({
    required Map<String, dynamic> data,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      // Map frontend fields to DB columns
      final dbData = <String, dynamic>{};
      if (data.containsKey('name')) dbData['nome'] = data['name'];
      if (data.containsKey('phone')) dbData['telefone'] = data['phone'];
      if (data.containsKey('cpf')) dbData['cpf'] = data['cpf'];
      if (data.containsKey('zipCode')) dbData['cep'] = data['zipCode'];
      if (data.containsKey('state')) dbData['estado'] = data['state'];
      if (data.containsKey('city')) dbData['cidade'] = data['city'];
      if (data.containsKey('street')) dbData['rua'] = data['street'];
      if (data.containsKey('number')) dbData['numero'] = data['number'];
      if (data.containsKey('neighborhood'))
        dbData['bairro'] = data['neighborhood'];
      if (data.containsKey('complement'))
        dbData['complemento'] = data['complement'];
      if (data.containsKey('birthDate')) {
        final date = data['birthDate'] as DateTime;
        dbData['datanascimento'] = date.toIso8601String();
      }
      if (data.containsKey('company')) dbData['empresa'] = data['company'];
      if (data.containsKey('nationality'))
        dbData['nacionalidade'] = data['nationality'];
      if (data.containsKey('passport'))
        dbData['n_passaporte'] = data['passport'];
      if (data.containsKey('ssn')) dbData['ssn'] = data['ssn'];

      await _supabaseClient.from('users').update(dbData).eq('id', userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Erro ao atualizar dados da conta: $e'));
    }
  }
}
