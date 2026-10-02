import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/medicine_detail_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/medicine_detail_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends MedicineDetailRemoteDataSource {
  Object? nextMedicineResponse;
  Object? nextPharmaciesResponse;
  bool medicineThrows = false;
  bool pharmaciesThrows = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getMedicine({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    if (medicineThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextMedicineResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    if (pharmaciesThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextPharmaciesResponse,
      statusCode: 200,
    );
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late MedicineDetailRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = MedicineDetailRepositoryImpl(remoteDataSource);
  });

  group('getMedicineDetail', () {
    test('parses the medicine out of the data envelope', () async {
      remoteDataSource.nextMedicineResponse = {
        'success': true,
        'data': {'id': 1, 'trade_name': 'Panadol', 'image_url': null},
      };

      final result = await repository.getMedicineDetail(medicineId: 1);

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data.tradeName, 'Panadol');
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.medicineThrows = true;

      final result = await repository.getMedicineDetail(medicineId: 1);

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('getMedicinePharmacies', () {
    test('parses the pharmacy rows out of the data list', () async {
      remoteDataSource.nextPharmaciesResponse = {
        'success': true,
        'data': [
          {'pharmacy_id': 11, 'name': 'صيدلية الأمل', 'price': 18, 'distance_km': 1.2},
          {'pharmacy_id': 12, 'name': 'صيدلية الشفاء', 'price': 20, 'distance_km': 2.5},
        ],
      };

      final result = await repository.getMedicinePharmacies(medicineId: 1);

      expect(result, isA<Success<Object?>>());
      final offers = (result as Success).data;
      expect(offers, hasLength(2));
      expect(offers.first.pharmacyName, 'صيدلية الأمل');
    });

    test('an empty list (no pharmacy stocks it) is a valid, non-error result', () async {
      remoteDataSource.nextPharmaciesResponse = {'success': true, 'data': <dynamic>[]};

      final result = await repository.getMedicinePharmacies(medicineId: 1);

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, isEmpty);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.pharmaciesThrows = true;

      final result = await repository.getMedicinePharmacies(medicineId: 1);

      expect(result, isA<ApiError<Object?>>());
    });
  });
}
