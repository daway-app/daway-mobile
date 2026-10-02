import '../../../../core/helpers/api_result.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<ApiResult<List<CartItem>>> getItems({required String token});

  /// `POST /patient/cart/items` — the server prices the line and merges a
  /// duplicate medicine into the existing one.
  Future<ApiResult<void>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  });

  /// `DELETE /patient/cart/items/{id}` — [itemId] is the cart line's own id.
  Future<ApiResult<void>> deleteItem({required String token, required int itemId});

  /// `DELETE /patient/cart` — empties the whole cart.
  Future<ApiResult<void>> clearCart({required String token});

  /// [quantity] must be at least 1; the cubit clamps before calling this
  /// (see [CartCubit.decrementQuantity]). [itemId] is the cart line's own id
  /// (CartItem.id), not a medicine or pharmacy id.
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  });
}
