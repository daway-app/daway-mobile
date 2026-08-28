import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_medicine_repository.dart';

class AddPharmacyMedicineUseCase {
  final PharmacyMedicineRepository _repository;
  final SessionRepository _sessionRepository;

  const AddPharmacyMedicineUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.addMedicine(
      token: session.token,
      medicineId: medicineId,
      mohMedicineId: mohMedicineId,
      price: price,
      quantity: quantity,
      isAvailable: isAvailable,
      imageUrl: imageUrl,
    );
  }
}
