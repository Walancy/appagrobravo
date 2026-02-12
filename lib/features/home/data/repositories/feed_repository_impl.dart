import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';
import 'package:agrobravo/features/home/domain/entities/comment_entity.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:agrobravo/features/home/data/models/post_model.dart';
import 'package:agrobravo/features/home/data/models/comment_model.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  final SupabaseClient _supabaseClient;

  FeedRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, List<PostEntity>>> getFeed() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      final response = await _supabaseClient
          .from('posts')
          .select('''
            *,
            users:user_id (nome, foto),
            missoes:missao_id (nome),
            curtidas:curtidas(user_id),
            comentarios:comentarios(id)
          ''')
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
            userId != null &&
            curtidasList != null &&
            curtidasList.any((c) => c['user_id'] == userId);

        return post
            .copyWith(
              userName: user?['nome'],
              userAvatar: user?['foto'],
              missionName: missao?['nome'],
              likesCount: likesCount,
              commentsCount: commentsCount,
              isLiked: isLiked,
            )
            .toEntity();
      }).toList();

      return Right(posts);
    } catch (e) {
      return Left(Exception('Erro ao buscar feed: $e'));
    }
  }

  @override
  Future<Either<Exception, List<CommentEntity>>> getComments(
    String postId,
  ) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      final response = await _supabaseClient
          .from('comentarios')
          .select('''
            *,
            users:user_id (nome, foto),
            curtidas_comentarios:curtidas_comentarios(user_id)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final allComments = (response as List).map((cMap) {
        final user = cMap['users'] as Map<String, dynamic>?;
        final curtidasList = cMap['curtidas_comentarios'] as List?;
        final likesCount = curtidasList?.length ?? 0;
        final isLiked =
            userId != null &&
            curtidasList != null &&
            curtidasList.any((c) => c['user_id'] == userId);

        return CommentModel.fromJson(cMap).copyWith(
          userName: user?['nome'],
          userAvatar: user?['foto'],
          likesCount: likesCount,
          isLiked: isLiked,
        );
      }).toList();

      // Build hierarchy
      final mainComments = allComments
          .where((c) => c.parentId == null)
          .toList();
      final replies = allComments.where((c) => c.parentId != null).toList();

      final entities = mainComments.map((main) {
        final commentReplies = replies
            .where((r) => r.parentId == main.id)
            .map((r) => r.toEntity())
            .toList();
        return main.toEntity(replies: commentReplies);
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(Exception('Erro ao buscar comentários: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> likePost(String postId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      await _supabaseClient.from('curtidas').insert({
        'post_id': postId,
        'user_id': userId,
      });

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao curtir post: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> unlikePost(String postId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      await _supabaseClient.from('curtidas').delete().match({
        'post_id': postId,
        'user_id': userId,
      });

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao remover curtida: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> likeComment(String commentId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      await _supabaseClient.from('curtidas_comentarios').insert({
        'comment_id': commentId,
        'user_id': userId,
      });

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao curtir comentário: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> unlikeComment(String commentId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      await _supabaseClient.from('curtidas_comentarios').delete().match({
        'comment_id': commentId,
        'user_id': userId,
      });

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao remover curtida do comentário: $e'));
    }
  }

  @override
  Future<Either<Exception, CommentEntity>> addComment(
    String postId,
    String text, {
    String? parentCommentId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final response = await _supabaseClient
          .from('comentarios')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'comentario': text,
            'id_comentario': parentCommentId,
          })
          .select('''
            *,
            users:user_id (nome, foto)
          ''')
          .single();

      final user = response['users'] as Map<String, dynamic>?;
      final model = CommentModel.fromJson(
        response,
      ).copyWith(userName: user?['nome'], userAvatar: user?['foto']);

      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception('Erro ao comentar: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> updateComment(
    String commentId,
    String text,
  ) async {
    try {
      await _supabaseClient
          .from('comentarios')
          .update({'comentario': text})
          .eq('id', commentId);
      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao atualizar comentário: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> deleteComment(String commentId) async {
    try {
      await _supabaseClient.from('comentarios').delete().eq('id', commentId);
      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao excluir comentário: $e'));
    }
  }

  @override
  Future<Either<Exception, PostEntity>> createPost({
    required List<String> imagePaths,
    required String caption,
    String? missionId,
    bool privado = false,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final List<String> imageUrls = [];

      for (final path in imagePaths) {
        final file = File(path);
        // Clean filename to avoid issues with special chars
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = path.split('.').last;
        final fileName = '${timestamp}_image.$ext';
        // Bucket is 'files', so we put it in 'posts' folder
        final storagePath = 'posts/$userId/$fileName';

        await _supabaseClient.storage.from('files').upload(storagePath, file);
        final url = _supabaseClient.storage
            .from('files')
            .getPublicUrl(storagePath);
        imageUrls.add(url);
      }

      final response = await _supabaseClient
          .from('posts')
          .insert({
            'user_id': userId,
            'missao_id': missionId,
            'imagens': imageUrls,
            'legenda': caption,
            'privado': privado,
          })
          .select('''
            *,
            users:user_id (nome, foto),
            missoes:missao_id (nome)
          ''')
          .single();

      final user = response['users'] as Map<String, dynamic>?;
      final missao = response['missoes'] as Map<String, dynamic>?;

      final likesCount = 0;
      final commentsCount = 0;
      final isLiked = false;

      final model = PostModel.fromJson(response).copyWith(
        userName: user?['nome'],
        userAvatar: user?['foto'],
        missionName: missao?['nome'],
        likesCount: likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked,
      );

      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception('Erro ao criar post: $e'));
    }
  }

  @override
  Future<Either<Exception, PostEntity>> updatePost({
    required String postId,
    required List<String> images,
    required String caption,
    String? missionId,
    required bool privado,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado.'));

      // Check ownership first
      final existingPost = await _supabaseClient
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();

      if (existingPost['user_id'] != userId) {
        return Left(Exception('Você não tem permissão para editar este post.'));
      }

      final List<String> finalImageUrls = [];

      for (final path in images) {
        // If it starts with http, it's an existing URL, keep it.
        if (path.startsWith('http')) {
          finalImageUrls.add(path);
        } else {
          // It's a local file path, upload it.
          final file = File(path);
          if (file.existsSync()) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final ext = path.split('.').last;
            final fileName = '${timestamp}_image_updated.$ext';
            final storagePath = 'posts/$userId/$fileName';

            await _supabaseClient.storage
                .from('files')
                .upload(storagePath, file);
            final url = _supabaseClient.storage
                .from('files')
                .getPublicUrl(storagePath);
            finalImageUrls.add(url);
          }
        }
      }

      final response = await _supabaseClient
          .from('posts')
          .update({
            'missao_id': missionId,
            'imagens': finalImageUrls,
            'legenda': caption,
            'privado': privado,
          })
          .eq('id', postId)
          .select('''
            *,
            users:user_id (nome, foto),
            missoes:missao_id (nome),
            curtidas:curtidas(user_id),
            comentarios:comentarios(id)
          ''')
          .single();

      final user = response['users'] as Map<String, dynamic>?;
      final missao = response['missoes'] as Map<String, dynamic>?;
      final curtidasList = response['curtidas'] as List?;
      final commentsList = response['comentarios'] as List?;
      final likesCount = curtidasList?.length ?? 0;
      final commentsCount = commentsList?.length ?? 0;
      final isLiked =
          userId != null &&
          (curtidasList?.any((c) => c['user_id'] == userId) ?? false);

      final model = PostModel.fromJson(response).copyWith(
        userName: user?['nome'],
        userAvatar: user?['foto'],
        missionName: missao?['nome'],
        likesCount: likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked,
      );

      return Right(model.toEntity());
    } catch (e) {
      return Left(Exception('Erro ao atualizar post: $e'));
    }
  }

  @override
  Future<Either<Exception, bool>> canUserPost() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Right(false);

      // Check if user is MASTER, COLABORADOR, or belongs to a mission (missoesParticipantes)
      final userProfile = await _supabaseClient
          .from('users')
          .select('tipouser')
          .eq('id', userId)
          .single();

      final roles = List<String>.from(userProfile['tipouser'] ?? []);
      if (roles.contains('MASTER') || roles.contains('COLABORADOR')) {
        return const Right(true);
      }

      final groupResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      return Right((groupResponse as List).isNotEmpty);
    } catch (e) {
      return Left(Exception('Erro ao verificar permissão: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MissionEntity>>> getUserMissions() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Right([]);

      // Fetch missions using a robust multi-step approach
      // 1. Get Group IDs the user belongs to
      final groupsResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('grupo_id')
          .eq('user_id', userId);

      final groupIds = (groupsResponse as List)
          .map((e) => e['grupo_id'] as String?)
          .where((e) => e != null)
          .cast<String>()
          .toList();

      if (groupIds.isEmpty) return const Right([]);

      // 2. Get Mission IDs from those Groups
      final groupsDetailsResponse = await _supabaseClient
          .from('grupos')
          .select('missao_id')
          .inFilter('id', groupIds);

      final missionIds = (groupsDetailsResponse as List)
          .map((e) => e['missao_id'] as String?)
          .where((e) => e != null)
          .cast<String>()
          .toSet() // Remove duplicates
          .toList();

      if (missionIds.isEmpty) return const Right([]);

      // 3. Fetch Mission Details
      final missionsResponse = await _supabaseClient
          .from('missoes')
          .select('id, nome, logo')
          .inFilter('id', missionIds);

      final missions = (missionsResponse as List).map((m) {
        return MissionEntity(
          id: m['id'],
          name: m['nome'] ?? 'Sem nome',
          logo: m['logo'],
        );
      }).toList();

      // Fallback: also check missoesParticipantes directly just in case some users are linked directly
      try {
        final directMissionsResponse = await _supabaseClient
            .from('missoesParticipantes')
            .select('missoes:missoes_id (id, nome, logo)')
            .eq('user_id', userId);

        final existingIds = missions.map((m) => m.id).toSet();

        for (final row in directMissionsResponse as List) {
          final missaoData = row['missoes'] ?? row['missoes_id'];
          if (missaoData is Map<String, dynamic>) {
            final id = missaoData['id']?.toString();
            if (id != null && !existingIds.contains(id)) {
              missions.add(
                MissionEntity(
                  id: id,
                  name: missaoData['nome']?.toString() ?? 'Sem nome',
                  logo: missaoData['logo']?.toString(),
                ),
              );
              existingIds.add(id);
            }
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar missões diretas: $e');
      }

      return Right(missions);
    } catch (e) {
      return Left(Exception('Erro ao buscar missões do usuário: $e'));
    }
  }

  @override
  Future<Either<Exception, MissionEntity?>> getLatestMissionAlert() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Right(null);

      // 1. Get the most recent group participation
      final groupResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select(
            'grupo_id, grupos:grupo_id (nome, data_inicio, logo, missoes:missao_id (id, nome, logo, localizacao))',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (groupResponse == null) return const Right(null);

      final groupData = groupResponse['grupos'] as Map<String, dynamic>?;
      if (groupData == null) return const Right(null);

      final missionData = groupData['missoes'] as Map<String, dynamic>?;
      if (missionData == null) return const Right(null);

      // 2. Count pending documents
      final docsResponse = await _supabaseClient
          .from('documentos')
          .select('tipo, status')
          .eq('user_id', userId);

      final docsList = docsResponse as List;
      final approvedTypes = docsList
          .where((d) => d['status'] == 'APROVADO')
          .map((d) => d['tipo'] as String)
          .toSet();

      final requiredTypes = [
        'PASSAPORTE',
        'VISTO',
        'VACINA',
        'SEGURO',
        'CARTEIRA_MOTORISTA',
        'AUTORIZACAO_MENORES',
      ];
      int pendingDocsCount = 0;
      for (final type in requiredTypes) {
        if (!approvedTypes.contains(type)) {
          pendingDocsCount++;
        }
      }

      // 3. Ensure a notification record exists for this mission addition
      try {
        final existingNotification = await _supabaseClient
            .from('notificacoes')
            .select('id')
            .eq('user_id', userId)
            .eq('tipo', 'missionUpdate')
            .eq('grupo_id', groupResponse['grupo_id'])
            .limit(1)
            .maybeSingle();

        if (existingNotification == null) {
          await _supabaseClient.from('notificacoes').insert({
            'user_id': userId,
            'assunto': 'missionUpdate',
            'tipo': 'missionUpdate', // Keeping for DB compatibility
            'grupo_id': groupResponse['grupo_id'],
            'missao_id': missionData['id'],
            'titulo': 'Nova Missão',
            'mensagem': 'Você foi adicionado à missão ${missionData['nome']}!',
            'lido': false,
          });
        }
      } catch (e) {
        debugPrint('Erro ao criar notificação de missão: $e');
      }

      return Right(
        MissionEntity(
          id: missionData['id']?.toString() ?? '',
          name: missionData['nome']?.toString() ?? 'Sem nome',
          logo: missionData['logo']?.toString(),
          location:
              missionData['localizacao']?.toString() ?? 'Destino em breve',
          startDate: groupData['data_inicio'] != null
              ? DateTime.tryParse(groupData['data_inicio'].toString())
              : null,
          groupName: groupData['nome']?.toString(),
          groupLogo: groupData['logo']?.toString(),
          pendingDocsCount: pendingDocsCount,
        ),
      );
    } catch (e) {
      return Left(Exception('Erro ao buscar alerta de missão: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> deletePost(String postId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado.'));

      // Check ownership
      final post = await _supabaseClient
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();

      if (post['user_id'] != userId) {
        return Left(
          Exception('Você não tem permissão para excluir este post.'),
        );
      }

      await _supabaseClient.from('posts').delete().eq('id', postId);

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao excluir post: $e'));
    }
  }

  @override
  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }
}
