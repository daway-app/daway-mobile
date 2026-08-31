enum NotificationType { lowStock, outOfStock, newInquiry, newRating, other }

/// Maps the backend's notification `type` string — confirmed live:
/// `low_stock`, `out_of_stock`, `new_inquiry`. `new_rating` is documented
/// ("تقييم جديد" triggers a pharmacy notification per the ratings feature)
/// but not yet observed on the demo backend; anything else falls back to
/// [NotificationType.other] rather than crashing on a future type.
NotificationType notificationTypeFrom(String? raw) {
  return switch (raw) {
    'low_stock' => NotificationType.lowStock,
    'out_of_stock' => NotificationType.outOfStock,
    'new_inquiry' => NotificationType.newInquiry,
    'new_rating' => NotificationType.newRating,
    _ => NotificationType.other,
  };
}

/// A pharmacy-facing notification (low/out of stock, a new patient inquiry,
/// a new rating, ...). The backend's `message` is already a full, ready-to
/// display sentence — the presentation layer only derives a per-[type]
/// title/icon on top of it.
class AppNotification {
  final int id;
  final NotificationType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

/// Shared by the الإشعارات screen's filter chips and its cubit.
enum NotificationFilter { all, unread, inquiries, inventory }

/// The full response shape of `GET /notifications`: the page of
/// notifications plus the backend's own `unread_count` — kept separate from
/// a client-side tally since the page may be a partial (paginated) view.
class NotificationsOverview {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsOverview({
    required this.notifications,
    required this.unreadCount,
  });
}
