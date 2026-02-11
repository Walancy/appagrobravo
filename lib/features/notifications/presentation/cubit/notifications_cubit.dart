import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:agrobravo/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_state.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository)
    : super(const NotificationsState.initial());

  Future<void> loadNotifications() async {
    emit(const NotificationsState.loading());
    final result = await _repository.getNotifications();
    result.fold(
      (failure) => emit(NotificationsState.error(failure.toString())),
      (notifications) => emit(NotificationsState.loaded(notifications)),
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    result.fold(
      (failure) => null, // Silently fail or log
      (_) {
        state.mapOrNull(
          loaded: (loadedState) {
            final updatedList = loadedState.notifications.map((n) {
              if (n.id == id) {
                return n.copyWith(isRead: true);
              }
              return n;
            }).toList();
            emit(NotificationsState.loaded(updatedList));
          },
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    result.fold((failure) => null, (_) {
      state.mapOrNull(
        loaded: (loadedState) {
          final updatedList = loadedState.notifications.map((n) {
            return n.copyWith(isRead: true);
          }).toList();
          emit(NotificationsState.loaded(updatedList));
        },
      );
    });
  }

  Future<void> respondFollowRequest(String userId, bool accept) async {
    final result = await _repository.respondFollowRequest(userId, accept);
    result.fold(
      (failure) => null,
      (_) => loadNotifications(), // Refresh to remove handled notification
    );
  }
}
