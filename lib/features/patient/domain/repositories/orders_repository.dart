import '../../../../core/helpers/api_result.dart';
import '../entities/order.dart';

abstract class OrdersRepository {
  Future<ApiResult<List<Order>>> getOrders({required String token});

  /// `POST /patient/orders/{id}/cancel` — only pending, confirmed and
  /// preparing orders can be cancelled; the server 422s otherwise and that
  /// message is surfaced as an ApiError.
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId});

  /// Creates an order from the patient's current cart. Returns the new
  /// order's id. 422s if the cart is empty, the address isn't the caller's,
  /// or an item is no longer available — surfaced as an ApiError message.
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  });
}
