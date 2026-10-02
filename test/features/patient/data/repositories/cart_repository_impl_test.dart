import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/cart_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/cart_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends CartRemoteDataSource {
  Object? nextCartResponse;
  bool getThrows = false;
  bool updateThrows = false;
  int? lastUpdatedItemId;
  int? lastUpdatedQuantity;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getCart({required String token}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextCartResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> updateItemQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    if (updateThrows) throw DioException(requestOptions: RequestOptions());
    lastUpdatedItemId = itemId;
    lastUpdatedQuantity = quantity;
    return Response(requestOptions: RequestOptions(), data: {'success': true}, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late CartRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = CartRepositoryImpl(remoteDataSource);
  });

  group('getItems', () {
    test('parses the cart lines out of the data envelope', () async {
      remoteDataSource.nextCartResponse = {
        'success': true,
        'data': {
          'id': 1,
          'items': [
            {
              'id': 7,
              'pharmacy_id': 11,
              'pharmacy_name': 'صيدلية النور',
              'pharmacy_medicine_id': 3,
              'medicine': {'id': 1, 'trade_name': 'Panadol', 'active_ingredient': 'Paracetamol'},
              'moh_medicine': null,
              'quantity': 2,
              'price': 18.0,
              'total': 36.0,
            },
          ],
          'subtotal': 36.0,
          'items_count': 2,
        },
      };

      final result = await repository.getItems(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final items = (result as Success).data;
      expect(items, hasLength(1));
      expect(items.single.id, 7);
      expect(items.single.medicineName, 'Panadol');
      expect(items.single.quantity, 2);
    });

    test('falls back to the moh_medicine name when the item has no general-catalog medicine',
        () async {
      remoteDataSource.nextCartResponse = {
        'success': true,
        'data': {
          'id': 1,
          'items': [
            {
              'id': 7,
              'pharmacy_id': 11,
              'pharmacy_name': 'صيدلية النور',
              'medicine': null,
              'moh_medicine': {'id': 5, 'trade_name': 'Adol'},
              'quantity': 1,
              'price': 10.0,
              'total': 10.0,
            },
          ],
          'subtotal': 10.0,
          'items_count': 1,
        },
      };

      final result = await repository.getItems(token: 'tok');

      expect((result as Success).data.single.medicineName, 'Adol');
    });

    test('an empty cart is a valid, non-error result', () async {
      remoteDataSource.nextCartResponse = {
        'success': true,
        'data': {'id': null, 'items': <dynamic>[], 'subtotal': 0},
      };

      final result = await repository.getItems(token: 'tok');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, isEmpty);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.getThrows = true;

      final result = await repository.getItems(token: 'tok');

      expect(result, isA<ApiError<Object?>>());
    });

    test('an unexpected response shape is an error, not a silently-empty cart', () async {
      // "items" missing/renamed — should not be confused with a real empty
      // cart (`'items': []`), which the test above confirms stays a Success.
      remoteDataSource.nextCartResponse = {
        'success': true,
        'data': {'id': 1, 'subtotal': 0},
      };

      final result = await repository.getItems(token: 'tok');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('updateQuantity', () {
    test('sends the item id and quantity through to the data source', () async {
      final result = await repository.updateQuantity(token: 'tok', itemId: 7, quantity: 5);

      expect(result, isA<Success<void>>());
      expect(remoteDataSource.lastUpdatedItemId, 7);
      expect(remoteDataSource.lastUpdatedQuantity, 5);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.updateThrows = true;

      final result = await repository.updateQuantity(token: 'tok', itemId: 7, quantity: 5);

      expect(result, isA<ApiError<Object?>>());
    });
  });
}
