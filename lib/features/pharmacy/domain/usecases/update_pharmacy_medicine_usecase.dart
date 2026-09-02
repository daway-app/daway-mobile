import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_medicine_repository.dart';

class UpdatePharmacyMedicineUseCase {
  final PharmacyMedicineRepository _repository;
  final SessionRepository _sessionRepository;

  const UpdatePharmacyMedicineUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    required int pharmacyMedicineId,
    required int medicineId,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.updateMedicine(
      token: session.token,
      pharmacyMedicineId: pharmacyMedicineId,
      medicineId: medicineId,
      tradeName: tradeName,
      tradeNameAr: tradeNameAr,
      activeIngredient: activeIngredient,
      price: price,
      quantity: quantity,
      isAvailable: isAvailable,
    );
  }
}
