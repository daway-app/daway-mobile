import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/orders_repository.dart';

class CancelOrderUseCase {
  final OrdersRepository _repository;
  final SessionRepository _sessionRepository;

  const CancelOrderUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call(int orderId) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.cancelOrder(token: session.token, orderId: orderId);
  }
}
