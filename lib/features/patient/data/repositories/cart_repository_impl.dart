import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  const CartRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<CartItem>>> getItems({required String token}) async {
    try {
      final response = await _remoteDataSource.getCart(token: token);
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final itemsRaw = data['items'];
      if (itemsRaw is! List) {
        throw FormatException('Unexpected GET /patient/cart response shape: ${response.data}');
      }
      final items = itemsRaw
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Success(items);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  }) async {
    try {
      await _remoteDataSource.addItem(
        token: token,
        pharmacyMedicineId: pharmacyMedicineId,
        pharmacyId: pharmacyId,
        medicineId: medicineId,
        quantity: quantity,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteItem({required String token, required int itemId}) async {
    try {
      await _remoteDataSource.deleteItem(token: token, itemId: itemId);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> clearCart({required String token}) async {
    try {
      await _remoteDataSource.clearCart(token: token);
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    try {
      await _remoteDataSource.updateItemQuantity(
        token: token,
        itemId: itemId,
        quantity: quantity,
      );
      return const Success(null);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
