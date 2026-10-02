import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/paginated_fetch.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  const OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async {
    try {
      final ordersJson = await fetchAllPages(
        source: 'GET /patient/orders',
        fetchPage: (page) async =>
            (await _remoteDataSource.getOrders(token: token, page: page)).data,
      );
      final orders = ordersJson
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(orders);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async {
    try {
      await _remoteDataSource.cancelOrder(token: token, orderId: orderId);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    try {
      final response = await _remoteDataSource.checkout(
        token: token,
        addressId: addressId,
        couponCode: couponCode,
        notes: notes,
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final orderId = (data['order_id'] as num?)?.toInt();
      if (orderId == null) {
        throw const FormatException('POST /patient/checkout response is missing order_id');
      }
      return Success(orderId);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
