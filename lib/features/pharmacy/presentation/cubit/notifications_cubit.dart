import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._markAllNotificationsReadUseCase,
    this._markNotificationReadUseCase,
  ) : super(const NotificationsLoading()) {
    load();
  }

  /// Only shows the full-screen loading state on a cold start or a retry
  /// from an error, same reasoning as PharmacyInquiriesCubit.load().
  Future<void> load() async {
    final previous = state;
    if (previous is! NotificationsLoaded) {
      emit(const NotificationsLoading());
    }
    final result = await _getNotificationsUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          NotificationsLoaded(
            notifications: data.notifications,
            unreadCount: data.unreadCount,
            filter: previous is NotificationsLoaded
                ? previous.filter
                : NotificationFilter.all,
            // Carried forward in case a future reload trigger (e.g.
            // pull-to-refresh) ever runs while a mark-as-read request from
            // before it is still in flight — without this, a second tap on
            // the same notification while that request resolves would slip
            // past markAsRead's markingIds guard.
            markingAllAsRead: previous is NotificationsLoaded
                ? previous.markingAllAsRead
                : false,
            markingIds: previous is NotificationsLoaded
                ? previous.markingIds
                : const {},
          ),
        );
      case ApiError(:final failure):
        emit(NotificationsLoadFailure(failure.message));
    }
  }

  void filterChanged(NotificationFilter filter) {
    final current = state;
    if (current is! NotificationsLoaded) return;
    emit(current.copyWith(filter: filter));
  }

  /// Returns null on success, or a user-facing error message on failure.
  /// Updates read state locally on success rather than reloading — a single
  /// notification flipping to read doesn't change anything else about the
  /// list, so a full server round-trip would just be wasted work.
  Future<String?> markAsRead(int notificationId) async {
    final current = state;
    if (current is! NotificationsLoaded ||
        current.markingIds.contains(notificationId)) {
      return null;
    }
    AppNotification? target;
    for (final n in current.notifications) {
      if (n.id == notificationId) {
        target = n;
        break;
      }
    }
    if (target == null || target.isRead) return null;

    emit(
      current.copyWith(markingIds: {...current.markingIds, notificationId}),
    );
    final result = await _markNotificationReadUseCase(
      notificationId: notificationId,
    );
    if (isClosed) return null;

    final latest = state;
    if (latest is! NotificationsLoaded) return null;
    switch (result) {
      case Success():
        emit(
          latest.copyWith(
            notifications: [
              for (final n in latest.notifications)
                if (n.id == notificationId) n.copyWith(isRead: true) else n,
            ],
            unreadCount: latest.unreadCount > 0
                ? latest.unreadCount - 1
                : 0,
            markingIds: latest.markingIds.difference({notificationId}),
          ),
        );
        return null;
      case ApiError(:final failure):
        emit(
          latest.copyWith(
            markingIds: latest.markingIds.difference({notificationId}),
          ),
        );
        return failure.message;
    }
  }

  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded || current.markingAllAsRead) {
      return null;
    }

    emit(current.copyWith(markingAllAsRead: true));
    final result = await _markAllNotificationsReadUseCase();
    if (isClosed) return null;

    final latest = state;
    if (latest is! NotificationsLoaded) return null;
    switch (result) {
      case Success():
        emit(
          latest.copyWith(
            notifications: [
              for (final n in latest.notifications) n.copyWith(isRead: true),
            ],
            unreadCount: 0,
            markingAllAsRead: false,
          ),
        );
        return null;
      case ApiError(:final failure):
        emit(latest.copyWith(markingAllAsRead: false));
        return failure.message;
    }
  }
}
