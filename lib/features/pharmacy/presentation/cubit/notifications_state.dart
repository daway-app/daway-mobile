import '../../domain/entities/notification.dart';

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoadFailure extends NotificationsState {
  final String message;

  const NotificationsLoadFailure(this.message);
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final NotificationFilter filter;

  /// True while "تحديد الكل كمقروء" is in flight.
  final bool markingAllAsRead;

  /// Ids of notifications with a mark-as-read request in flight — guards
  /// against a duplicate tap firing a second request for the same one.
  final Set<int> markingIds;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.filter = NotificationFilter.all,
    this.markingAllAsRead = false,
    this.markingIds = const {},
  });

  List<AppNotification> get filteredNotifications {
    return switch (filter) {
      NotificationFilter.all => notifications,
      NotificationFilter.unread =>
        notifications.where((n) => !n.isRead).toList(),
      NotificationFilter.inquiries => notifications
          .where((n) => n.type == NotificationType.newInquiry)
          .toList(),
      NotificationFilter.inventory => notifications
          .where(
            (n) =>
                n.type == NotificationType.lowStock ||
                n.type == NotificationType.outOfStock,
          )
          .toList(),
    };
  }

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    NotificationFilter? filter,
    bool? markingAllAsRead,
    Set<int>? markingIds,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      filter: filter ?? this.filter,
      markingAllAsRead: markingAllAsRead ?? this.markingAllAsRead,
      markingIds: markingIds ?? this.markingIds,
    );
  }
}
