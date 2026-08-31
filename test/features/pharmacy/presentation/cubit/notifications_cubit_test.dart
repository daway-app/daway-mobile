import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/notification.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/notifications_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_notifications_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/mark_notification_read_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/notifications_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _unreadLowStock = AppNotification(
  id: 1,
  type: NotificationType.lowStock,
  message: 'تنبيه نقص مخزون',
  isRead: false,
  createdAt: DateTime(2026, 8, 30),
);
final _unreadInquiry = AppNotification(
  id: 2,
  type: NotificationType.newInquiry,
  message: 'استفسار جديد',
  isRead: false,
  createdAt: DateTime(2026, 8, 29),
);
final _readRating = AppNotification(
  id: 3,
  type: NotificationType.newRating,
  message: 'تقييم جديد',
  isRead: true,
  createdAt: DateTime(2026, 8, 28),
);

class _FakeNotificationsRepository implements NotificationsRepository {
  ApiResult<NotificationsOverview> getResult = Success(
    NotificationsOverview(
      notifications: [_unreadLowStock, _unreadInquiry, _readRating],
      unreadCount: 2,
    ),
  );
  ApiResult<void> markAllResult = const Success(null);
  ApiResult<void> markOneResult = const Success(null);
  int markOneCallCount = 0;
  int? lastMarkedId;
  Completer<void>? markOneGate;

  @override
  Future<ApiResult<NotificationsOverview>> getNotifications({
    required String token,
  }) async => getResult;

  @override
  Future<ApiResult<void>> markAllAsRead({required String token}) async =>
      markAllResult;

  @override
  Future<ApiResult<void>> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    markOneCallCount++;
    lastMarkedId = notificationId;
    if (markOneGate != null) await markOneGate!.future;
    return markOneResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(
    accountType: AccountType.pharmacy,
    token: 'tok-1',
  );

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

void main() {
  late _FakeNotificationsRepository repository;
  late NotificationsCubit cubit;

  setUp(() async {
    repository = _FakeNotificationsRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = NotificationsCubit(
      GetNotificationsUseCase(repository, sessionRepository),
      MarkAllNotificationsReadUseCase(repository, sessionRepository),
      MarkNotificationReadUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads notifications with the backend unread count', () {
    final state = cubit.state as NotificationsLoaded;
    expect(state.notifications, hasLength(3));
    expect(state.unreadCount, 2);
    expect(state.filter, NotificationFilter.all);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<NotificationsLoadFailure>());
  });

  test('filterChanged(inventory) narrows to low/out-of-stock notifications', () {
    cubit.filterChanged(NotificationFilter.inventory);

    final state = cubit.state as NotificationsLoaded;
    expect(state.filteredNotifications, [_unreadLowStock]);
  });

  test('filterChanged(inquiries) narrows to new-inquiry notifications', () {
    cubit.filterChanged(NotificationFilter.inquiries);

    final state = cubit.state as NotificationsLoaded;
    expect(state.filteredNotifications, [_unreadInquiry]);
  });

  test('filterChanged(unread) narrows to unread notifications', () {
    cubit.filterChanged(NotificationFilter.unread);

    final state = cubit.state as NotificationsLoaded;
    expect(state.filteredNotifications, [_unreadLowStock, _unreadInquiry]);
  });

  test(
    'markAsRead flips the notification locally and decrements unreadCount without reloading',
    () async {
      final error = await cubit.markAsRead(1);

      expect(error, isNull);
      expect(repository.lastMarkedId, 1);
      final state = cubit.state as NotificationsLoaded;
      expect(state.notifications.firstWhere((n) => n.id == 1).isRead, true);
      expect(state.unreadCount, 1);
      expect(state.markingIds, isEmpty);
    },
  );

  test('markAsRead on an already-read notification is a no-op', () async {
    final error = await cubit.markAsRead(3);

    expect(error, isNull);
    expect(repository.markOneCallCount, 0);
  });

  test(
    'a second markAsRead call for the same id while one is in flight is a no-op',
    () async {
      repository.markOneGate = Completer<void>();

      final first = cubit.markAsRead(1);
      final second = await cubit.markAsRead(1);

      expect(second, isNull);
      repository.markOneGate!.complete();
      await first;

      expect(repository.markOneCallCount, 1);
    },
  );

  test('markAsRead surfaces an error and keeps the notification unread', () async {
    repository.markOneResult = const ApiError(ApiFailure(message: 'فشل التحديث'));

    final error = await cubit.markAsRead(1);

    expect(error, 'فشل التحديث');
    final state = cubit.state as NotificationsLoaded;
    expect(state.notifications.firstWhere((n) => n.id == 1).isRead, false);
    expect(state.unreadCount, 2);
    expect(state.markingIds, isEmpty);
  });

  test('markAllAsRead flips every notification and zeroes unreadCount', () async {
    final error = await cubit.markAllAsRead();

    expect(error, isNull);
    final state = cubit.state as NotificationsLoaded;
    expect(state.notifications.every((n) => n.isRead), true);
    expect(state.unreadCount, 0);
    expect(state.markingAllAsRead, false);
  });

  test('markAllAsRead surfaces an error and leaves notifications untouched', () async {
    repository.markAllResult = const ApiError(ApiFailure(message: 'فشل'));

    final error = await cubit.markAllAsRead();

    expect(error, 'فشل');
    final state = cubit.state as NotificationsLoaded;
    expect(state.unreadCount, 2);
    expect(state.markingAllAsRead, false);
  });
}
