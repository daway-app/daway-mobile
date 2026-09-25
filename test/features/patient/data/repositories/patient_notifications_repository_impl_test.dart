import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/patient_notifications_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/patient_notifications_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PatientNotificationsRemoteDataSource {
  /// The body served for each 1-based page.
  final Map<int, Object?> pages = {};
  bool throws = false;
  String? lastToken;
  final List<int> requestedPages = [];

  _StubRemoteDataSource() : super(Dio());

  /// The body of page 1, for the single-page cases.
  set nextResponse(Object? value) => pages[1] = value;

  @override
  Future<Response<dynamic>> getNotifications({required String token, int page = 1}) async {
    lastToken = token;
    requestedPages.add(page);
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: pages[page], statusCode: 200);
  }
}

Map<String, dynamic> _notification(int id, String createdAt, {String type = 'system'}) => {
      'id': id,
      'type': type,
      'message': 'message $id',
      'is_read': false,
      'created_at': createdAt,
    };

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PatientNotificationsRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PatientNotificationsRepositoryImpl(remoteDataSource);
  });

  test('parses the notifications newest first, passing the token through', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        _notification(1, '2026-09-22T10:00:00Z'),
        _notification(2, '2026-09-24T10:00:00Z', type: 'reminder'),
        _notification(3, '2026-09-23T10:00:00Z'),
      ],
      'unread_count': 3,
      'pagination': {'total': 3, 'per_page': 20, 'current_page': 1, 'last_page': 1},
    };

    final result = await repository.getNotifications(token: 'tok-1');

    expect(remoteDataSource.lastToken, 'tok-1');
    expect(result, isA<Success<Object?>>());
    final notifications = (result as Success).data;
    expect(notifications.map((n) => n.id), [2, 3, 1]);
  });

  test('skips a malformed record instead of failing the whole list', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        _notification(1, '2026-09-22T10:00:00Z'),
        {'type': 'system'}, // no id / created_at
        _notification(3, '2026-09-23T10:00:00Z'),
      ],
    };

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data.map((n) => n.id), [3, 1]);
  });

  test('an empty list is a valid, non-error result', () async {
    remoteDataSource.nextResponse = {'success': true, 'data': [], 'unread_count': 0};

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data, isEmpty);
  });

  test('surfaces a network failure instead of throwing', () async {
    remoteDataSource.throws = true;

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('an unexpected response shape is mapped to a failure, not an unhandled exception', () async {
    remoteDataSource.nextResponse = {'unexpected': 'shape'};

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('reads every page and sorts across them, so notifications beyond the first page are not dropped', () async {
    remoteDataSource.pages[1] = {
      'data': [_notification(1, '2026-09-20T10:00:00Z'), _notification(2, '2026-09-22T10:00:00Z')],
      'pagination': {'total': 3, 'per_page': 2, 'current_page': 1, 'last_page': 2},
    };
    remoteDataSource.pages[2] = {
      'data': [_notification(3, '2026-09-24T10:00:00Z')],
      'pagination': {'total': 3, 'per_page': 2, 'current_page': 2, 'last_page': 2},
    };

    final result = await repository.getNotifications(token: 'tok-1');

    expect(remoteDataSource.requestedPages, [1, 2]);
    expect((result as Success).data.map((n) => n.id), [3, 2, 1]);
  });

  test('records that all fail to parse are an error, not the "no notifications" state', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        {'type': 'system'}, // no id / created_at
        {'id': 2, 'type': 'system', 'created_at': 'not a date'},
      ],
    };

    final result = await repository.getNotifications(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });
}
