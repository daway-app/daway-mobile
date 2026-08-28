import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_medicine_repository.dart';

class DeletePharmacyMedicineUseCase {
  final PharmacyMedicineRepository _repository;
  final SessionRepository _sessionRepository;

  const DeletePharmacyMedicineUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call(int pharmacyMedicineId) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.deleteMedicine(token: session.token, pharmacyMedicineId: pharmacyMedicineId);
  }
}
