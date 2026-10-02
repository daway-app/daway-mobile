import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/pharmacies_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/pharmacies_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PharmaciesRemoteDataSource {
  Object? nextListResponse;
  Object? nextDetailResponse;
  bool listThrows = false;
  bool detailThrows = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getPharmacies() async {
    if (listThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextListResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> getPharmacyDetail(int pharmacyId) async {
    if (detailThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextDetailResponse, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PharmaciesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PharmaciesRepositoryImpl(remoteDataSource);
  });

  group('getNearbyPharmacies', () {
    remoteSetUp() {
      remoteDataSource.nextListResponse = {
        'success': true,
        'data': [
          {
            'id': 1,
            'pharmacy_name': 'صيدلية الأمل',
            'latitude': 31.5016,
            'longitude': 34.4668,
            'is_open_now': true,
          },
          {
            'id': 2,
            'pharmacy_name': 'صيدلية الشفاء',
            'latitude': 32.2238,
            'longitude': 35.2627,
            'is_open_now': false,
          },
        ],
      };
    }

    test('parses every row without coordinates when no user location is given', () async {
      remoteSetUp();

      final result = await repository.getNearbyPharmacies();

      expect(result, isA<Success<Object?>>());
      final pharmacies = (result as Success).data;
      expect(pharmacies, hasLength(2));
      expect(pharmacies.every((p) => p.distanceKm == null), isTrue);
    });

    test('computes distanceKm and sorts nearest-first when a user location is given', () async {
      remoteSetUp();

      // Closer to Nablus (id 2) than to Gaza (id 1).
      final result = await repository.getNearbyPharmacies(
        userLatitude: 32.0,
        userLongitude: 35.2,
      );

      final pharmacies = (result as Success).data as List;
      expect(pharmacies.first.id, 2);
      expect(pharmacies.first.distanceKm, lessThan(pharmacies.last.distanceKm));
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.listThrows = true;

      final result = await repository.getNearbyPharmacies();

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('getWorkingHoursLabel', () {
    test('formats an "open"/"close" pair as an Arabic AM/PM range', () async {
      remoteDataSource.nextDetailResponse = {
        'success': true,
        'data': {
          'id': 1,
          'hours': [
            {'day': 'monday', 'open': '09:00', 'close': '22:00'},
          ],
        },
      };

      final result = await repository.getWorkingHoursLabel(1);

      expect(result, isA<Success<String?>>());
      expect((result as Success).data, '9 ص - 10 م');
    });

    test('an empty hours array returns null instead of a fabricated time', () async {
      remoteDataSource.nextDetailResponse = {
        'success': true,
        'data': {'id': 1, 'hours': <dynamic>[]},
      };

      final result = await repository.getWorkingHoursLabel(1);

      expect((result as Success).data, isNull);
    });

    test('an unrecognized hours shape returns null instead of throwing', () async {
      remoteDataSource.nextDetailResponse = {
        'success': true,
        'data': {'id': 1, 'hours': 'unexpected-string-shape'},
      };

      final result = await repository.getWorkingHoursLabel(1);

      expect(result, isA<Success<String?>>());
      expect((result as Success).data, isNull);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.detailThrows = true;

      final result = await repository.getWorkingHoursLabel(1);

      expect(result, isA<ApiError<String?>>());
    });
  });
}
