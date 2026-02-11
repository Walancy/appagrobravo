import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/notifications/domain/entities/notification_entity.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = _Initial;
  const factory NotificationsState.loading() = _Loading;
  const factory NotificationsState.loaded(
    List<NotificationEntity> notifications,
  ) = _Loaded;
  const factory NotificationsState.error(String message) = _Error;
}

extension NotificationsStateX on NotificationsState {
  bool get hasUnread {
    return maybeWhen(
      loaded: (notifications) => notifications.any((n) => !n.isRead),
      orElse: () => false,
    );
  }
}
