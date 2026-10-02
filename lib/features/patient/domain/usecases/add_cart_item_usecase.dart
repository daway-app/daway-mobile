import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/cart_repository.dart';

class AddCartItemUseCase {
  final CartRepository _repository;
  final SessionRepository _sessionRepository;

  const AddCartItemUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    int quantity = 1,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.addItem(
      token: session.token,
      pharmacyMedicineId: pharmacyMedicineId,
      pharmacyId: pharmacyId,
      medicineId: medicineId,
      quantity: quantity,
    );
  }
}
