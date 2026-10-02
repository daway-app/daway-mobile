import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/orders_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/orders_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends OrdersRemoteDataSource {
  /// Response for page 1 when [pageResponses] has no explicit entry for it.
  Object? nextOrdersResponse;

  /// Explicit per-page responses — set these to test multi-page walks.
  final Map<int, Object?> pageResponses = {};
  Object? nextCheckoutResponse;
  bool getThrows = false;
  bool checkoutThrows = false;
  int? lastAddressId;
  final List<int> requestedPages = [];

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getOrders({required String token, int page = 1}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    requestedPages.add(page);
    final data = pageResponses[page] ?? (page == 1 ? nextOrdersResponse : null);
    return Response(requestOptions: RequestOptions(), data: data, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    if (checkoutThrows) throw DioException(requestOptions: RequestOptions());
    lastAddressId = addressId;
    return Response(
      requestOptions: RequestOptions(),
      data: nextCheckoutResponse,
      statusCode: 200,
    );
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late OrdersRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = OrdersRepositoryImpl(remoteDataSource);
  });

  group('getOrders', () {
    test('parses the order rows out of the data list', () async {
      remoteDataSource.nextOrdersResponse = {
        'success': true,
        'data': [
          {'id': 1, 'status': 'confirmed', 'total': 25.0, 'items_count': 1},
        ],
        'pagination': {'total': 1, 'last_page': 1},
      };

      final result = await repository.getOrders(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final orders = (result as Success).data;
      expect(orders, hasLength(1));
      expect(orders.first.orderNumber, '1');
    });

    test('walks every page instead of only returning the first 20 orders', () async {
      remoteDataSource.pageResponses[1] = {
        'success': true,
        'data': [
          {'id': 1, 'status': 'confirmed', 'total': 10.0, 'items_count': 1},
        ],
        'pagination': {'total': 2, 'last_page': 2},
      };
      remoteDataSource.pageResponses[2] = {
        'success': true,
        'data': [
          {'id': 2, 'status': 'pending', 'total': 20.0, 'items_count': 1},
        ],
        'pagination': {'total': 2, 'last_page': 2},
      };

      final result = await repository.getOrders(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final orders = (result as Success).data;
      expect(orders.map((o) => o.orderNumber), ['1', '2']);
      expect(remoteDataSource.requestedPages, [1, 2]);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.getThrows = true;

      final result = await repository.getOrders(token: 'tok');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('checkout', () {
    test('sends the address id and returns the new order id', () async {
      remoteDataSource.nextCheckoutResponse = {
        'success': true,
        'data': {'order_id': 42, 'subtotal': 25.0, 'discount': 0, 'total': 25.0},
      };

      final result = await repository.checkout(token: 'tok', addressId: 1);

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, 42);
      expect(remoteDataSource.lastAddressId, 1);
    });

    test('a response missing order_id is an error, not a fabricated order 0', () async {
      remoteDataSource.nextCheckoutResponse = {
        'success': true,
        'data': {'subtotal': 25.0, 'discount': 0, 'total': 25.0},
      };

      final result = await repository.checkout(token: 'tok', addressId: 1);

      expect(result, isA<ApiError<Object?>>());
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.checkoutThrows = true;

      final result = await repository.checkout(token: 'tok', addressId: 1);

      expect(result, isA<ApiError<Object?>>());
    });
  });
}
