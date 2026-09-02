import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_medicine_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_medicine_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides every network call to return a canned response instead of
/// hitting the network, so this test can lock in the exact wire field names
/// the backend expects (`medicine_id`, `moh_medicine_id`, `image_url`) and
/// how tolerant the list-parsing is to different envelope shapes, without a
/// live server.
class _CapturingRemoteDataSource extends PharmacyMedicineRemoteDataSource {
  Map<String, dynamic>? lastBody;
  int? lastPharmacyMedicineId;
  Object? nextListResponse;

  _CapturingRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> addMedicine({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    lastBody = body;
    return Response(requestOptions: RequestOptions(), statusCode: 201);
  }

  @override
  Future<Response<dynamic>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required Map<String, dynamic> body,
  }) async {
    lastPharmacyMedicineId = pharmacyMedicineId;
    lastBody = body;
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }

  @override
  Future<Response<dynamic>> addMedicineByName({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    lastBody = body;
    return Response(requestOptions: RequestOptions(), statusCode: 201);
  }

  @override
  Future<Response<dynamic>> getMedicines({required String token}) async {
    return Response(requestOptions: RequestOptions(), data: nextListResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> searchCatalog({required String token, required String query}) async {
    return Response(requestOptions: RequestOptions(), data: nextListResponse, statusCode: 200);
  }
}

void main() {
  late _CapturingRemoteDataSource remoteDataSource;
  late PharmacyMedicineRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _CapturingRemoteDataSource();
    repository = PharmacyMedicineRepositoryImpl(remoteDataSource);
  });

  test('searchCatalog parses the real {data: {medicines: [...]}} envelope', () async {
    // Captured from a live GET /pharmacy/medicines/search?q=pan response.
    remoteDataSource.nextListResponse = {
      'success': true,
      'message': 'تم البحث بنجاح',
      'data': {
        'medicines': [
          {'type': 'medicine', 'id': 11, 'name': 'PANADOL TABLET', 'sub': 'PANADOL TABLET'},
        ],
      },
    };

    final result = await repository.searchCatalog(token: 'tok-1', query: 'pan');

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data, hasLength(1));
  });

  test('searchCatalog merges data.medicines and data.moh_catalog into one list', () async {
    // Captured from a live GET /pharmacy/medicines/search?q=the response —
    // an empty general list alongside two Ministry of Health matches.
    remoteDataSource.nextListResponse = {
      'success': true,
      'data': {
        'medicines': [],
        'moh_catalog': [
          {
            'type': 'moh',
            'id': 3,
            'name': 'DR. MANAR ALARAJ NOURSHING & STRENGTHENING ORGANIC HAIR OIL',
            'sub': 'Dr. Manar Alaraj Cosmetics Factory/Palestine',
            'official_price': null,
          },
          {
            'type': 'moh',
            'id': 21,
            'name': 'THE HOPPA. BETTER GLOW VIT C SERUM',
            'sub': 'Orientco Limited/Turkey',
            'official_price': null,
          },
        ],
      },
    };

    final result = await repository.searchCatalog(token: 'tok-1', query: 'the');

    expect(result, isA<Success<Object?>>());
    final items = (result as Success).data as List;
    expect(items, hasLength(2));
    expect(items[0].id, 3);
    expect(items[0].type, 'moh');
  });

  group('getMedicines tolerates the real envelope shape, whichever it is', () {
    test('a flat {data: [...]} object', () async {
      remoteDataSource.nextListResponse = {
        'data': [
          {'id': 5, 'name': 'Panadol'},
        ],
      };

      final result = await repository.getMedicines(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, hasLength(1));
    });

    test('a Laravel-paginated {data: {data: [...]}} object', () async {
      remoteDataSource.nextListResponse = {
        'data': {
          'data': [
            {'id': 5, 'name': 'Panadol'},
          ],
          'current_page': 1,
        },
      };

      final result = await repository.getMedicines(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, hasLength(1));
    });

    test('a bare top-level array', () async {
      remoteDataSource.nextListResponse = [
        {'id': 5, 'name': 'Panadol'},
      ];

      final result = await repository.getMedicines(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, hasLength(1));
    });

    test('an unrecognized shape surfaces as an ApiError instead of throwing unhandled', () async {
      remoteDataSource.nextListResponse = {'unexpected': 'shape'};

      final result = await repository.getMedicines(token: 'tok-1');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  test('addMedicine sends medicine_id for a general-catalog id, not moh_medicine_id', () async {
    await repository.addMedicine(
      token: 'tok-1',
      medicineId: 16,
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    final body = remoteDataSource.lastBody!;
    expect(body['medicine_id'], 16);
    expect(body.containsKey('moh_medicine_id'), isFalse);
  });

  test('addMedicine sends moh_medicine_id for a Ministry of Health id, not medicine_id', () async {
    // Confirmed against a live 422 response: the backend requires exactly
    // one of medicine_id or moh_medicine_id.
    await repository.addMedicine(
      token: 'tok-1',
      mohMedicineId: 21,
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    final body = remoteDataSource.lastBody!;
    expect(body['moh_medicine_id'], 21);
    expect(body.containsKey('medicine_id'), isFalse);
  });

  test('addMedicine includes image_url only when provided', () async {
    await repository.addMedicine(
      token: 'tok-1',
      medicineId: 16,
      price: 12.5,
      quantity: 40,
      isAvailable: true,
      imageUrl: 'https://res.cloudinary.com/demo/image/upload/medicine.jpg',
    );

    expect(remoteDataSource.lastBody!['image_url'],
        'https://res.cloudinary.com/demo/image/upload/medicine.jpg');

    await repository.addMedicine(
      token: 'tok-1',
      medicineId: 16,
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    expect(remoteDataSource.lastBody!.containsKey('image_url'), isFalse);
  });

  test('addMedicineByName sends trade_name and omits optional fields when absent', () async {
    await repository.addMedicineByName(
      token: 'tok-1',
      tradeName: 'Abod panadol',
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    final body = remoteDataSource.lastBody!;
    expect(body['trade_name'], 'Abod panadol');
    expect(body['price'], 12.5);
    expect(body['quantity'], 40);
    expect(body['is_available'], isTrue);
    expect(body.containsKey('trade_name_ar'), isFalse);
    expect(body.containsKey('active_ingredient'), isFalse);
    expect(body.containsKey('min_stock'), isFalse);
  });

  test('addMedicineByName includes trade_name_ar and active_ingredient when provided', () async {
    await repository.addMedicineByName(
      token: 'tok-1',
      tradeName: 'Abod panadol',
      tradeNameAr: 'بانادول أبو',
      activeIngredient: 'Paracetamol',
      price: 12.5,
      quantity: 40,
      isAvailable: true,
    );

    final body = remoteDataSource.lastBody!;
    expect(body['trade_name_ar'], 'بانادول أبو');
    expect(body['active_ingredient'], 'Paracetamol');
  });

  test('updateMedicine sends medicine_id and the stock fields for the given pharmacy medicine id',
      () async {
    // Confirmed against the team's Postman collection ("Update Medicine",
    // PUT /pharmacy/medicines/{id}): the body includes medicine_id even
    // though the record is already identified by the path.
    await repository.updateMedicine(
      token: 'tok-1',
      pharmacyMedicineId: 9,
      medicineId: 16,
      tradeName: 'Adol 4',
      tradeNameAr: 'ادول 4',
      activeIngredient: '44',
      price: 18,
      quantity: 25,
      isAvailable: false,
    );

    expect(remoteDataSource.lastPharmacyMedicineId, 9);
    final body = remoteDataSource.lastBody!;
    expect(body['medicine_id'], 16);
    expect(body['trade_name'], 'Adol 4');
    expect(body['trade_name_ar'], 'ادول 4');
    expect(body['active_ingredient'], '44');
    expect(body['price'], 18);
    expect(body['quantity'], 25);
    expect(body['is_available'], isFalse);
  });
}
