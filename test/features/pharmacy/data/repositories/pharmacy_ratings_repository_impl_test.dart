import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_ratings_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_ratings_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PharmacyRatingsRemoteDataSource {
  Object? nextGetResponse;
  bool getThrows = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getRatings({required String token}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextGetResponse,
      statusCode: 200,
    );
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PharmacyRatingsRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PharmacyRatingsRepositoryImpl(remoteDataSource);
  });

  test(
    'parses the ratings list and derives the average and star breakdown',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'stars': 5,
            'comment': 'خدمة ممتازة',
            'created_at': '2026-08-22 16:32:25',
            'user': {'id': 36, 'name': 'أحمد العتيبي'},
          },
          {
            'id': 2,
            'stars': 4,
            'comment': null,
            'created_at': '2026-08-18 10:00:00',
            'patient': {'id': 40, 'name': 'سارة الحربي'},
          },
        ],
        'pagination': {
          'total': 128,
          'per_page': 100,
          'current_page': 1,
          'last_page': 2,
        },
      };

      final result = await repository.getRatings(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.totalCount, 128);
      expect(overview.averageRating, 4.5);
      expect(overview.starCounts, {5: 1, 4: 1, 3: 0, 2: 0, 1: 0});
      expect(overview.ratings, hasLength(2));
      // Newest first regardless of the order the API returned them in.
      expect(overview.ratings.first.id, 1);
      expect(overview.ratings.first.patientName, 'أحمد العتيبي');
      expect(overview.ratings.first.comment, 'خدمة ممتازة');
      expect(overview.ratings.last.patientName, 'سارة الحربي');
    },
  );

  test('an empty ratings list has a zero average and all-zero counts', () async {
    remoteDataSource.nextGetResponse = {
      'data': [],
      'pagination': {'total': 0, 'per_page': 100, 'current_page': 1, 'last_page': 1},
    };

    final result = await repository.getRatings(token: 'tok-1');

    final overview = (result as Success).data;
    expect(overview.totalCount, 0);
    expect(overview.averageRating, 0.0);
    expect(overview.starCounts, {5: 0, 4: 0, 3: 0, 2: 0, 1: 0});
  });

  test(
    'a malformed record among otherwise-valid ratings is skipped, not fatal',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'stars': 5,
            'created_at': '2026-08-22 16:32:25',
            'user': {'id': 36, 'name': 'أحمد'},
          },
          {'id': 2, 'user': 'not-an-object'},
        ],
      };

      final result = await repository.getRatings(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.ratings, hasLength(1));
      expect(overview.ratings.single.id, 1);
    },
  );

  test(
    'a record with a missing stars value is skipped instead of counted as a 0-star rating',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'stars': 5,
            'created_at': '2026-08-22 16:32:25',
            'user': {'name': 'أحمد'},
          },
          {
            'id': 2,
            'created_at': '2026-08-22 16:32:25',
            'user': {'name': 'بدون تقييم'},
          },
        ],
      };

      final result = await repository.getRatings(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.ratings, hasLength(1));
      expect(overview.averageRating, 5.0);
    },
  );

  test(
    'a record with a missing created_at is skipped instead of sorting to the top as "now"',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'stars': 5,
            'created_at': '2020-01-01 00:00:00',
            'user': {'name': 'قديم لكن صالح'},
          },
          {'id': 2, 'stars': 4, 'user': {'name': 'بدون تاريخ'}},
        ],
      };

      final result = await repository.getRatings(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.ratings, hasLength(1));
      expect(overview.ratings.single.id, 1);
    },
  );

  test(
    'a malformed pagination object falls back to the parsed count instead of failing the request',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'stars': 5,
            'created_at': '2026-08-22 16:32:25',
            'user': {'name': 'أحمد'},
          },
        ],
        'pagination': 'not-an-object',
      };

      final result = await repository.getRatings(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.ratings, hasLength(1));
      expect(overview.totalCount, 1);
    },
  );

  test('falls back to the parsed list length when pagination is missing', () async {
    remoteDataSource.nextGetResponse = {
      'data': [
        {
          'id': 1,
          'stars': 3,
          'created_at': '2026-08-22 16:32:25',
          'user': {'name': 'محمد'},
        },
      ],
    };

    final result = await repository.getRatings(token: 'tok-1');

    final overview = (result as Success).data;
    expect(overview.totalCount, 1);
  });

  test('a network failure surfaces as an ApiError', () async {
    remoteDataSource.getThrows = true;

    final result = await repository.getRatings(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });
}
