import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase {
  final CartRepository _repository;
  final SessionRepository _sessionRepository;

  const UpdateCartItemQuantityUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({required int itemId, required int quantity}) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.updateQuantity(
      token: session.token,
      itemId: itemId,
      quantity: quantity,
    );
  }
}
