import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository _repository;
  final SessionRepository _sessionRepository;

  const GetOrdersUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<Order>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getOrders(token: session.token);
  }
}
