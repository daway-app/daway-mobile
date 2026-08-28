import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_inventory_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_inventory_repository_impl.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides every network call to return a canned response instead of
/// hitting the network, so this test can lock in the exact wire field names
/// the backend expects (`id`, `quantity`, `is_available`) and how tolerant
/// the list-parsing is to different envelope shapes, without a live server.
class _CapturingRemoteDataSource extends PharmacyInventoryRemoteDataSource {
  Map<String, dynamic>? lastBody;
  Object? nextListResponse;

  _CapturingRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getInventory({required String token}) async {
    return Response(requestOptions: RequestOptions(), data: nextListResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> bulkUpdate({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    lastBody = body;
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }
}

void main() {
  late _CapturingRemoteDataSource remoteDataSource;
  late PharmacyInventoryRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _CapturingRemoteDataSource();
    repository = PharmacyInventoryRepositoryImpl(remoteDataSource);
  });

  group('getInventory tolerates the real envelope shape, whichever it is', () {
    test('a flat {data: [...]} object', () async {
      remoteDataSource.nextListResponse = {
        'data': [
          {'id': 5, 'quantity': 30, 'medicine': {'trade_name': 'Panadol'}},
        ],
      };

      final result = await repository.getInventory(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, hasLength(1));
    });

    test('a Laravel-paginated {data: {data: [...]}} object', () async {
      remoteDataSource.nextListResponse = {
        'data': {
          'data': [
            {'id': 5, 'quantity': 30, 'medicine': {'trade_name': 'Panadol'}},
          ],
          'current_page': 1,
        },
      };

      final result = await repository.getInventory(token: 'tok-1');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, hasLength(1));
    });

    test('an unrecognized shape surfaces as an ApiError instead of throwing unhandled', () async {
      remoteDataSource.nextListResponse = {'unexpected': 'shape'};

      final result = await repository.getInventory(token: 'tok-1');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  test('updateInventory sends id/quantity/is_available for every item', () async {
    await repository.updateInventory(
      token: 'tok-1',
      items: const [
        InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 25, isAvailable: true),
        InventoryItemUpdate(pharmacyMedicineId: 2, quantity: 0, isAvailable: false),
      ],
    );

    final items = remoteDataSource.lastBody!['items'] as List;
    expect(items, hasLength(2));
    expect(items[0], {'id': 1, 'quantity': 25, 'is_available': true});
    expect(items[1], {'id': 2, 'quantity': 0, 'is_available': false});
  });
}
