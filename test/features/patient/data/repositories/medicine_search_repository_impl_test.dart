import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/medicine_search_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/medicine_search_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends MedicineSearchRemoteDataSource {
  Object? nextResponse;
  bool throws = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> search(String query) async {
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextResponse, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late MedicineSearchRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = MedicineSearchRepositoryImpl(remoteDataSource);
  });

  test('parses the pharmacy-backed medicines out of the data.medicines envelope', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': {
        'medicines': [
          {
            'id': 1,
            'trade_name': 'Panadol',
            'active_ingredient': 'Paracetamol',
            'image_url': null,
            'is_available': 1,
            'available_pharmacies_count': 1,
          },
        ],
        'moh_catalog': [
          {'id': 21157, 'trade_name': 'PANADOL TABLET'},
        ],
      },
    };

    final result = await repository.search('panadol');

    expect(result, isA<Success<Object?>>());
    final medicines = (result as Success).data;
    expect(medicines, hasLength(1));
    expect(medicines.single.tradeName, 'Panadol');
    expect(medicines.single.availablePharmaciesCount, 1);
  });

  test('an empty medicines list (moh_catalog-only match) is a valid, non-error result', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': {'medicines': [], 'moh_catalog': []},
    };

    final result = await repository.search('vitamin');

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data, isEmpty);
  });

  test('surfaces a network failure instead of throwing', () async {
    remoteDataSource.throws = true;

    final result = await repository.search('panadol');

    expect(result, isA<ApiError<Object?>>());
  });

  test('an unexpected response shape is mapped to a failure, not an unhandled exception', () async {
    remoteDataSource.nextResponse = {'unexpected': 'shape'};

    final result = await repository.search('panadol');

    expect(result, isA<ApiError<Object?>>());
  });
}
