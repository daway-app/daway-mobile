import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/notifications_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/notifications_repository_impl.dart';
import 'package:daway_app/features/pharmacy/domain/entities/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends NotificationsRemoteDataSource {
  Object? nextGetResponse;
  bool getThrows = false;
  bool markAllThrows = false;
  bool markAsReadThrows = false;
  int? lastMarkedId;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getNotifications({required String token}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextGetResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> markAllAsRead({required String token}) async {
    if (markAllThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }

  @override
  Future<Response<dynamic>> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    if (markAsReadThrows) throw DioException(requestOptions: RequestOptions());
    lastMarkedId = notificationId;
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = NotificationsRepositoryImpl(remoteDataSource);
  });

  test(
    'parses the notifications list, sorted newest first, with the backend unread_count',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 3,
            'type': 'new_inquiry',
            'message': 'استفسار جديد عن توفر دواء',
            'is_read': false,
            'created_at': '2026-08-22 16:32:25',
          },
          {
            'id': 16,
            'type': 'low_stock',
            'message': 'تنبيه نقص مخزون دواء Panadol',
            'is_read': false,
            'created_at': '2026-08-30 14:17:59',
          },
        ],
        'unread_count': 13,
        'pagination': {'total': 13, 'per_page': 100, 'current_page': 1, 'last_page': 1},
      };

      final result = await repository.getNotifications(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.unreadCount, 13);
      expect(overview.notifications, hasLength(2));
      expect(overview.notifications.first.id, 16);
      expect(overview.notifications.first.type, NotificationType.lowStock);
      expect(overview.notifications.last.id, 3);
    },
  );

  test('an unrecognized type falls back to NotificationType.other', () async {
    remoteDataSource.nextGetResponse = {
      'data': [
        {
          'id': 1,
          'type': 'account_updated',
          'message': 'تم تحديث حالة الحساب',
          'is_read': true,
          'created_at': '2026-08-22 16:32:25',
        },
      ],
    };

    final result = await repository.getNotifications(token: 'tok-1');

    final overview = (result as Success).data;
    expect(overview.notifications.single.type, NotificationType.other);
    expect(overview.notifications.single.isRead, true);
  });

  test(
    'a record with a missing id is skipped instead of colliding as id 0',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'type': 'low_stock',
            'message': 'صالح',
            'created_at': '2026-08-22 16:32:25',
          },
          {
            'type': 'low_stock',
            'message': 'بدون id',
            'created_at': '2026-08-22 16:32:25',
          },
        ],
      };

      final result = await repository.getNotifications(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.notifications, hasLength(1));
      expect(overview.notifications.single.id, 1);
    },
  );

  test(
    'a record with a missing created_at is skipped instead of sorting to the top as "now"',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'type': 'low_stock',
            'message': 'قديم لكن صالح',
            'created_at': '2020-01-01 00:00:00',
          },
          {'id': 2, 'type': 'low_stock', 'message': 'بدون تاريخ'},
        ],
      };

      final result = await repository.getNotifications(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.notifications, hasLength(1));
      expect(overview.notifications.single.id, 1);
    },
  );

  test(
    'falls back to a client-side unread tally when unread_count is malformed',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'type': 'low_stock',
            'message': 'a',
            'is_read': false,
            'created_at': '2026-08-22 16:32:25',
          },
          {
            'id': 2,
            'type': 'low_stock',
            'message': 'b',
            'is_read': true,
            'created_at': '2026-08-22 16:32:25',
          },
        ],
        'unread_count': 'not-a-number',
      };

      final result = await repository.getNotifications(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.unreadCount, 1);
    },
  );

  test('a network failure surfaces as an ApiError', () async {
    remoteDataSource.getThrows = true;

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('markAllAsRead succeeds', () async {
    final result = await repository.markAllAsRead(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
  });

  test('markAllAsRead surfaces a failure as an ApiError', () async {
    remoteDataSource.markAllThrows = true;

    final result = await repository.markAllAsRead(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('markAsRead sends the given id', () async {
    final result = await repository.markAsRead(
      token: 'tok-1',
      notificationId: 9,
    );

    expect(result, isA<Success<Object?>>());
    expect(remoteDataSource.lastMarkedId, 9);
  });

  test('markAsRead surfaces a failure as an ApiError', () async {
    remoteDataSource.markAsReadThrows = true;

    final result = await repository.markAsRead(
      token: 'tok-1',
      notificationId: 9,
    );

    expect(result, isA<ApiError<Object?>>());
  });
}
