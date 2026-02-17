import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  final SupabaseClient _supabaseClient;

  FeedRepositoryImpl(this._supabaseClient);

  Future<void> _saveFeedToCache(List<PostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = posts.map((p) => p.toJson()).toList();
      await prefs.setString('cached_feed', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar feed no cache: $e');
    }
  }

  Future<List<PostModel>> _getFeedFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_feed');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Erro ao recuperar feed do cache: $e');
    }
    return [];
  }

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

        return post.copyWith(
          userName: user?['nome'],
          userAvatar: user?['foto'],
          missionName: missao?['nome'],
          likesCount: likesCount,
          commentsCount: commentsCount,
          isLiked: isLiked,
        );
      }).toList();

      await _saveFeedToCache(posts);

      return Right(posts.map((e) => e.toEntity()).toList());
    } catch (e) {
      debugPrint('Erro ao buscar feed online: $e. Tentando cache offline.');
      final cachedPosts = await _getFeedFromCache();
      if (cachedPosts.isNotEmpty) {
        return Right(cachedPosts.map((e) => e.toEntity()).toList());
      }
      return Left(Exception('Erro ao buscar feed e sem cache disponível: $e'));
    }
  }

  Future<void> _saveCommentsToCache(
    String postId,
    List<dynamic> jsonList,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_comments_$postId', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar comentários no cache: $e');
    }
  }

  Future<List<CommentModel>> _getCommentsFromCache(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_comments_$postId');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((cMap) {
          final user = cMap['users'] as Map<String, dynamic>?;
          // If 'curtidas_comentarios' was cached it is a List
          final curtidasList = cMap['curtidas_comentarios'] as List?;
          final likesCount = curtidasList?.length ?? 0;
          // We might not have current userId context easily during cache retrieval for isLiked,
          // but we can try if client is available or default to false.
          // However, to keep it consistent with 'getFeed', we can try to access auth.
          // Note: _supabaseClient might be persistent.
          final userId = _supabaseClient.auth.currentUser?.id;
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
      }
    } catch (e) {
      debugPrint('Erro ao recuperar comentários do cache: $e');
    }
    return [];
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

      final List<dynamic> data = response as List;
      await _saveCommentsToCache(postId, data);

      final allComments = data.map((cMap) {
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
      debugPrint('Erro ao buscar comentários online: $e. Tentando cache.');
      final cachedComments = await _getCommentsFromCache(postId);
      if (cachedComments.isNotEmpty) {
        // Build hierarchy from cache
        final mainComments = cachedComments
            .where((c) => c.parentId == null)
            .toList();
        final replies = cachedComments
            .where((c) => c.parentId != null)
            .toList();

        final entities = mainComments.map((main) {
          final commentReplies = replies
              .where((r) => r.parentId == main.id)
              .map((r) => r.toEntity())
              .toList();
          return main.toEntity(replies: commentReplies);
        }).toList();

        return Right(entities);
      }
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
    required List<dynamic> images,
    required String caption,
    String? missionId,
    bool privado = false,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      final List<String> imageUrls = [];
      debugPrint('CREATE_POST: Processing ${images.length} images');

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        Uint8List fileBytes;
        String fileName;
        debugPrint('IMAGE $i: type=${image.runtimeType}');

        if (image is XFile) {
          fileBytes = await image.readAsBytes();
          final ext = image.name.split('.').last;
          final extension = ext.isNotEmpty && ext.length < 5 ? ext : 'jpg';
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          fileName = '${timestamp}_image.$extension';
        } else if (image is String) {
          if (kIsWeb) {
            continue;
          }
          final file = File(image);
          fileBytes = await file.readAsBytes();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final ext = image.split('.').last;
          fileName = '${timestamp}_image.$ext';
        } else {
          continue;
        }

        final storagePath = 'posts/$userId/$fileName';

        await _supabaseClient.storage
            .from('files')
            .uploadBinary(storagePath, fileBytes);
        final url = _supabaseClient.storage
            .from('files')
            .getPublicUrl(storagePath);
        debugPrint('IMAGE $i: upload success, url: $url');
        imageUrls.add(url);
      }

      debugPrint(
        'CREATE_POST: Inserting into DB with ${imageUrls.length} urls',
      );

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
    required List<dynamic> images,
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

      for (final image in images) {
        // If it starts with http, it's an existing URL, keep it.
        if (image is String && image.startsWith('http')) {
          finalImageUrls.add(image);
          continue;
        }

        Uint8List fileBytes;
        String fileName;

        if (image is XFile) {
          fileBytes = await image.readAsBytes();
          final ext = image.name.split('.').last;
          final extension = ext.isNotEmpty && ext.length < 5 ? ext : 'jpg';
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          fileName = '${timestamp}_image_updated.$extension';
        } else if (image is String) {
          if (kIsWeb) {
            continue;
          }
          final file = File(image);
          if (!file.existsSync()) continue;

          fileBytes = await file.readAsBytes();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final ext = image.split('.').last;
          fileName = '${timestamp}_image_updated.$ext';
        } else {
          continue;
        }

        final storagePath = 'posts/$userId/$fileName';

        await _supabaseClient.storage
            .from('files')
            .uploadBinary(storagePath, fileBytes);
        final url = _supabaseClient.storage
            .from('files')
            .getPublicUrl(storagePath);
        finalImageUrls.add(url);
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

  Future<void> _saveCanUserPostToCache(bool canPost) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cached_can_user_post', canPost);
    } catch (e) {
      debugPrint('Erro ao salvar permissão de postagem no cache: $e');
    }
  }

  Future<bool?> _getCanUserPostFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('cached_can_user_post');
    } catch (e) {
      debugPrint('Erro ao recuperar permissão de postagem do cache: $e');
    }
    return null;
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
        await _saveCanUserPostToCache(true);
        return const Right(true);
      }

      final groupResponse = await _supabaseClient
          .from('gruposParticipantes')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      final canPost = (groupResponse as List).isNotEmpty;
      await _saveCanUserPostToCache(canPost);

      return Right(canPost);
    } catch (e) {
      debugPrint('Erro ao verificar permissão online: $e. Tentando cache.');
      final cached = await _getCanUserPostFromCache();
      if (cached != null) {
        return Right(cached);
      }
      return Left(Exception('Erro ao verificar permissão: $e'));
    }
  }

  Future<void> _saveUserMissionsToCache(List<MissionEntity> missions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = missions
          .map(
            (m) => {
              'id': m.id,
              'name': m.name,
              'logo': m.logo,
              // Save other fields if present, though getUserMissions mainly uses these
              'location': m.location,
              'groupName': m.groupName,
            },
          )
          .toList();
      await prefs.setString('cached_user_missions', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Erro ao salvar missões no cache: $e');
    }
  }

  Future<List<MissionEntity>> _getUserMissionsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_user_missions');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map(
              (json) => MissionEntity(
                id: json['id'],
                name: json['name'],
                logo: json['logo'],
                location: json['location'],
                groupName: json['groupName'],
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao recuperar missões do cache: $e');
    }
    return [];
  }

  Future<void> _saveMissionAlertToCache(MissionEntity? mission) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mission == null) {
        await prefs.remove('cached_mission_alert');
        return;
      }
      final json = {
        'id': mission.id,
        'name': mission.name,
        'logo': mission.logo,
        'location': mission.location,
        'groupName': mission.groupName,
        'pendingDocsCount': mission.pendingDocsCount,
        'passaporteObrigatorio': mission.passaporteObrigatorio,
        'vistoObrigatorio': mission.vistoObrigatorio,
        'vacinaObrigatoria': mission.vacinaObrigatoria,
        'seguroObrigatorio': mission.seguroObrigatorio,
        'carteiraObrigatoria': mission.carteiraObrigatoria,
        'autorizacaoObrigatoria': mission.autorizacaoObrigatoria,
        'startDate': mission.startDate?.toIso8601String(),
        'endDate': mission.endDate?.toIso8601String(),
      };
      await prefs.setString('cached_mission_alert', jsonEncode(json));
    } catch (e) {
      debugPrint('Erro ao salvar alerta de missão no cache: $e');
    }
  }

  Future<MissionEntity?> _getMissionAlertFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_mission_alert');
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return MissionEntity(
          id: json['id'],
          name: json['name'],
          logo: json['logo'],
          location: json['location'],
          groupName: json['groupName'],
          pendingDocsCount: json['pendingDocsCount'] ?? 0,
          passaporteObrigatorio: json['passaporteObrigatorio'] ?? false,
          vistoObrigatorio: json['vistoObrigatorio'] ?? false,
          vacinaObrigatoria: json['vacinaObrigatoria'] ?? false,
          seguroObrigatorio: json['seguroObrigatorio'] ?? false,
          carteiraObrigatoria: json['carteiraObrigatoria'] ?? false,
          autorizacaoObrigatoria: json['autorizacaoObrigatoria'] ?? false,
          startDate: json['startDate'] != null
              ? DateTime.parse(json['startDate'])
              : null,
          endDate: json['endDate'] != null
              ? DateTime.parse(json['endDate'])
              : null,
        );
      }
    } catch (e) {
      debugPrint('Erro ao recuperar alerta de missão do cache: $e');
    }
    return null;
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

      if (groupIds.isEmpty) {
        // Clear cache if online but empty? Not strictly necessary but consistent.
        await _saveUserMissionsToCache([]);
        return const Right([]);
      }

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

      if (missionIds.isEmpty) {
        await _saveUserMissionsToCache([]);
        return const Right([]);
      }

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
            .select('missao:missoes_id (id, nome:nome_viagem, logo:imagem)')
            .eq('user_id', userId);

        final existingIds = missions.map((m) => m.id).toSet();

        for (final row in directMissionsResponse as List) {
          final missaoData = row['missao'];
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

      await _saveUserMissionsToCache(missions);

      return Right(missions);
    } catch (e) {
      debugPrint('Erro ao buscar missões do usuário: $e. Tentando cache.');
      final cachedMissions = await _getUserMissionsFromCache();
      if (cachedMissions.isNotEmpty) {
        return Right(cachedMissions);
      }
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
            'grupo_id, grupos:grupo_id (nome, data_inicio, data_fim, logo, missoes:missao_id (id, nome, logo, localizacao, passaporte_obrigatorio, visto_obrigatorio, vacina_obrigatorio, seguro_obrigatorio, cnh_obrigatorio, autorizacao_obrigatorio))',
          )
          .eq('user_id', userId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (groupResponse == null) {
        await _saveMissionAlertToCache(null);
        return const Right(null);
      }

      final grupoData = groupResponse['grupos'] as Map<String, dynamic>?;
      if (grupoData == null) {
        await _saveMissionAlertToCache(null);
        return const Right(null);
      }

      final missionData = grupoData['missoes'] as Map<String, dynamic>?;
      if (missionData == null) {
        await _saveMissionAlertToCache(null);
        return const Right(null);
      }

      final missionId = missionData['id'] as String;

      final startDate = grupoData['data_inicio'] != null
          ? DateTime.tryParse(grupoData['data_inicio'].toString())
          : null;
      final endDate = grupoData['data_fim'] != null
          ? DateTime.tryParse(grupoData['data_fim'].toString())
          : null;

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

      // Get mandatory flags from mission
      final bool passReq = missionData['passaporte_obrigatorio'] ?? false;
      final bool visaReq = missionData['visto_obrigatorio'] ?? false;
      final bool vacReq = missionData['vacina_obrigatorio'] ?? false;
      final bool segReq = missionData['seguro_obrigatorio'] ?? false;
      final bool cnhReq = missionData['cnh_obrigatorio'] ?? false;
      final bool autReq = missionData['autorizacao_obrigatorio'] ?? false;

      final requiredTypes = [
        if (passReq) 'PASSAPORTE',
        if (visaReq) 'VISTO',
        if (vacReq) 'VACINA',
        if (segReq) 'SEGURO',
        if (cnhReq) 'CARTEIRA_MOTORISTA',
        if (autReq) 'AUTORIZACAO_MENORES',
      ];

      // If no flags are set, fallback to a default set (backwards compatibility)
      final effectiveRequiredTypes = requiredTypes.isEmpty
          ? ['PASSAPORTE', 'VISTO', 'VACINA', 'SEGURO']
          : requiredTypes;

      int pendingCount = 0;
      for (var type in effectiveRequiredTypes) {
        if (!approvedTypes.contains(type)) {
          pendingCount++;
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

      final missionEntity = MissionEntity(
        id: missionId,
        name: missionData['nome'] ?? 'Sua Missão',
        logo: missionData['logo'],
        location: missionData['localizacao'],
        groupName: grupoData['nome'],
        pendingDocsCount: pendingCount,
        passaporteObrigatorio: passReq,
        vistoObrigatorio: visaReq,
        vacinaObrigatoria: vacReq,
        seguroObrigatorio: segReq,
        carteiraObrigatoria: cnhReq,
        autorizacaoObrigatoria: autReq,
        startDate: startDate,
        endDate: endDate,
      );

      await _saveMissionAlertToCache(missionEntity);

      return Right(missionEntity);
    } catch (e) {
      debugPrint('Erro ao buscar alerta de missão online: $e. Tentando cache.');
      final cachedAlert = await _getMissionAlertFromCache();
      if (cachedAlert != null) {
        return Right(cachedAlert);
      }
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
