import 'package:agrobravo/features/notifications/data/models/notification_model.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';
import 'package:agrobravo/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  final SupabaseClient _supabaseClient;

  NotificationsRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Exception, List<NotificationEntity>>> getNotifications() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      // Fetch notifications
      final response = await _supabaseClient
          .from('notificacoes')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;

      // Collect unique requester IDs to fetch their profiles
      final requesterIds = data
          .where((n) => n['solicitacao_user_id'] != null)
          .map((n) => n['solicitacao_user_id'] as String)
          .toSet()
          .toList();

      Map<String, dynamic> profilesMap = {};
      if (requesterIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabaseClient
              .from('users')
              .select('id, nome, foto')
              .inFilter('id', requesterIds);

          for (var profile in (profilesResponse as List)) {
            profilesMap[profile['id']] = profile;
          }
        } catch (_) {}
      }

      // Collect post IDs for thumbnails
      final postIds = data
          .where((n) => n['post_id'] != null)
          .map((n) => n['post_id'] as String)
          .toSet()
          .toList();

      Map<String, String> postThumbnails = {};
      Map<String, String> postOwners = {};
      if (postIds.isNotEmpty) {
        try {
          final postsResponse = await _supabaseClient
              .from('posts')
              .select('id, imagens, user_id')
              .inFilter('id', postIds);

          for (var post in (postsResponse as List)) {
            final imgs = post['imagens'] as List?;
            if (imgs != null && imgs.isNotEmpty) {
              postThumbnails[post['id']] = imgs.first as String;
            }
            postOwners[post['id']] = post['user_id'] as String;
          }
        } catch (_) {}
      }

      final notifications = data.map((json) {
        final model = NotificationModel.fromJson(json);
        final solicitanteId = json['solicitacao_user_id'] as String?;
        final profile = solicitanteId != null
            ? profilesMap[solicitanteId]
            : null;

        final postId = json['post_id'] as String?;
        final postThumbnail = postId != null ? postThumbnails[postId] : null;
        final postOwnerId = postId != null ? postOwners[postId] : null;

        return model
            .copyWith(userName: profile?['nome'], userAvatar: profile?['foto'])
            .toEntity()
            .copyWith(postImage: postThumbnail, postOwnerId: postOwnerId);
      }).toList();

      return Right(notifications);
    } catch (e) {
      return Left(Exception('Erro ao buscar notificações: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> markAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notificacoes')
          .update({'lido': true})
          .eq('id', notificationId);
      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao marcar como lida: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> markAllAsRead() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return Left(Exception('Usuário não autenticado'));

      await _supabaseClient
          .from('notificacoes')
          .update({'lido': true})
          .eq('user_id', userId)
          .eq('lido', false);
      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao marcar todas como lidas: $e'));
    }
  }

  @override
  Future<Either<Exception, Unit>> respondFollowRequest(
    String userId,
    bool accept,
  ) async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId == null)
        return Left(Exception('Usuário não autenticado'));

      if (accept) {
        await _supabaseClient.from('conexoes').update({'aprovou': true}).match({
          'seguidor_id': userId,
          'seguido_id': currentUserId,
        });
      } else {
        await _supabaseClient.from('conexoes').delete().match({
          'seguidor_id': userId,
          'seguido_id': currentUserId,
        });
      }

      // Update notification status if exists
      await _supabaseClient
          .from('notificacoes')
          .update({'solicitacaorespondida': true, 'lido': true})
          .match({'solicitacao_user_id': userId, 'user_id': currentUserId});

      return const Right(unit);
    } catch (e) {
      return Left(Exception('Erro ao responder solicitação: $e'));
    }
  }
}
