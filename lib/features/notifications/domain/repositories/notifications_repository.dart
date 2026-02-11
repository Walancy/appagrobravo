import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Exception, List<NotificationEntity>>> getNotifications();
  Future<Either<Exception, Unit>> markAsRead(String notificationId);
  Future<Either<Exception, Unit>> markAllAsRead();
  Future<Either<Exception, Unit>> respondFollowRequest(
    String userId,
    bool accept,
  );
}
