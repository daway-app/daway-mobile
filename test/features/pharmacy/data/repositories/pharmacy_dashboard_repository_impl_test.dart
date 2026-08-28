import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_dashboard_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_dashboard_repository_impl.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_dashboard_stats.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides both network calls this repository combines, so this test can
/// lock in the wire field names confirmed against a live response
/// (`total_medicines`, `available_count`, `low_count`, `out_count`,
/// `pending_inquiries`, `low_stock_items`) without hitting the network.
class _StubRemoteDataSource extends PharmacyDashboardRemoteDataSource {
  Object? nextStatsResponse;
  Object? nextRatingsResponse;
  Object? nextInquiriesResponse;
  bool statsThrows = false;
  bool ratingsThrows = false;
  bool inquiriesThrows = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getStats({required String token}) async {
    if (statsThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextStatsResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> getRatings({required String token}) async {
    if (ratingsThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextRatingsResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> getRecentInquiries({required String token}) async {
    if (inquiriesThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextInquiriesResponse,
      statusCode: 200,
    );
  }
}

const _statsJson = {
  'data': {
    'total_medicines': 13,
    'available_count': 12,
    'low_count': 1,
    'out_count': 1,
    'pending_inquiries': 2,
    'total_inquiries': 5,
    'new_ratings_this_week': 0,
    'latest_ratings': [],
    'low_stock_items': [
      {
        'pharmacy_medicine_id': 14,
        'medicine_id': 17,
        'trade_name': 'بندل',
        'active_ingredient': 'بمبو',
        'quantity': 8,
      },
    ],
  },
};

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PharmacyDashboardRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PharmacyDashboardRepositoryImpl(remoteDataSource);
    remoteDataSource.nextStatsResponse = _statsJson;
    remoteDataSource.nextRatingsResponse = {'data': []};
    remoteDataSource.nextInquiriesResponse = {'data': []};
  });

  test('combines the counts from the dashboard stats endpoint', () async {
    final result = await repository.getDashboardStats(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
    final stats = (result as Success).data;
    expect(stats.totalMedicines, 13);
    expect(stats.availableCount, 12);
    expect(stats.lowStockCount, 1);
    expect(stats.outOfStockCount, 1);
    expect(stats.newInquiriesCount, 2);
  });

  test('parses low_stock_items from the same response', () async {
    final result = await repository.getDashboardStats(token: 'tok-1');

    final stats = (result as Success).data;
    expect(stats.lowStockItems, hasLength(1));
    expect(stats.lowStockItems.single.tradeName, 'بندل');
    expect(stats.lowStockItems.single.quantity, 8);
  });

  test(
    'averages the stars from the ratings endpoint, since the stats endpoint has none',
    () async {
      remoteDataSource.nextRatingsResponse = {
        'data': [
          {'stars': 5},
          {'stars': 3},
          {'stars': 4},
        ],
      };

      final result = await repository.getDashboardStats(token: 'tok-1');

      final stats = (result as Success).data;
      expect(stats.averageRating, 4.0);
      expect(stats.ratingsCount, 3);
    },
  );

  test(
    'averageRating is null (not zero) when the pharmacy has no ratings yet',
    () async {
      final result = await repository.getDashboardStats(token: 'tok-1');

      final stats = (result as Success).data;
      expect(stats.averageRating, isNull);
      expect(stats.ratingsCount, 0);
    },
  );

  test(
    'an unrecognized ratings response shape degrades to no rating data instead of failing the whole call',
    () async {
      remoteDataSource.nextRatingsResponse = {'unexpected': 'shape'};

      final result = await repository.getDashboardStats(token: 'tok-1');

      // The stats counts are the primary content of this screen; a malformed
      // /pharmacy/ratings response shouldn't blank those out too.
      expect(result, isA<Success<Object?>>());
      final stats = (result as Success).data;
      expect(stats.totalMedicines, 13);
      expect(stats.averageRating, isNull);
      expect(stats.ratingsCount, 0);
    },
  );

  test(
    'a network failure fetching ratings also degrades to no rating data',
    () async {
      remoteDataSource.ratingsThrows = true;

      final result = await repository.getDashboardStats(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final stats = (result as Success).data;
      expect(stats.totalMedicines, 13);
      expect(stats.averageRating, isNull);
    },
  );

  test(
    'a non-numeric stars value on one rating record is skipped, not fatal',
    () async {
      remoteDataSource.nextRatingsResponse = {
        'data': [
          {'stars': 5},
          {'stars': 'not-a-number'},
          {'stars': 3},
        ],
      };

      final result = await repository.getDashboardStats(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final stats = (result as Success).data;
      expect(stats.averageRating, 4.0);
      expect(stats.ratingsCount, 2);
    },
  );

  test(
    'a stats-endpoint failure still fails the whole call — it is the primary content',
    () async {
      remoteDataSource.statsThrows = true;

      final result = await repository.getDashboardStats(token: 'tok-1');

      expect(result, isA<ApiError<Object?>>());
    },
  );

  test(
    'parses recent inquiries, including nested user/medicine names',
    () async {
      remoteDataSource.nextInquiriesResponse = {
        'data': [
          {
            'id': 1,
            'status': 'answered',
            'message': 'هل يتوفر هذا الدواء؟',
            'created_at': '2026-08-22 16:32:25',
            'user': {'id': 36, 'name': 'أحمد محمد'},
            'medicine': {'id': 6, 'trade_name': 'sgd'},
          },
        ],
      };

      final result = await repository.getDashboardStats(token: 'tok-1');

      final stats = (result as Success).data;
      expect(stats.recentInquiries, hasLength(1));
      final inquiry = stats.recentInquiries.single;
      expect(inquiry.message, 'هل يتوفر هذا الدواء؟');
      expect(inquiry.status, PharmacyInquiryStatus.answered);
      expect(inquiry.patientName, 'أحمد محمد');
      expect(inquiry.medicineName, 'sgd');
      expect(inquiry.createdAt, DateTime(2026, 8, 22, 16, 32, 25));
    },
  );

  test(
    'an unrecognized inquiries response shape degrades to an empty preview instead of failing the whole call',
    () async {
      remoteDataSource.nextInquiriesResponse = {'unexpected': 'shape'};

      final result = await repository.getDashboardStats(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data.recentInquiries, isEmpty);
    },
  );

  test(
    'a network failure fetching inquiries also degrades to an empty preview',
    () async {
      remoteDataSource.inquiriesThrows = true;

      final result = await repository.getDashboardStats(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final stats = (result as Success).data;
      expect(stats.recentInquiries, isEmpty);
      expect(stats.totalMedicines, 13);
    },
  );

  test(
    'a malformed record among otherwise-valid inquiries is skipped, not fatal to the rest',
    () async {
      remoteDataSource.nextInquiriesResponse = {
        'data': [
          {
            'id': 1,
            'status': 'answered',
            'message': 'هل يتوفر هذا الدواء؟',
            'created_at': '2026-08-22 16:32:25',
            'user': {'id': 36, 'name': 'أحمد محمد'},
            'medicine': {'id': 6, 'trade_name': 'sgd'},
          },
          // A record whose `medicine` is a string instead of an object —
          // should be skipped, not blank out the well-formed record above.
          {
            'id': 2,
            'status': 'new',
            'message': 'استفسار آخر',
            'created_at': '2026-08-23 10:00:00',
            'user': {'id': 40, 'name': 'سارة'},
            'medicine': 'not-an-object',
          },
        ],
      };

      final result = await repository.getDashboardStats(token: 'tok-1');

      final stats = (result as Success).data;
      expect(stats.recentInquiries, hasLength(1));
      expect(stats.recentInquiries.single.id, 1);
    },
  );
}
