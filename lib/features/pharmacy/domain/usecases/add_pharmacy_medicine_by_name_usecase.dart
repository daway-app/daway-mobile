import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/pharmacy_medicine_repository.dart';

class AddPharmacyMedicineByNameUseCase {
  final PharmacyMedicineRepository _repository;
  final SessionRepository _sessionRepository;

  const AddPharmacyMedicineByNameUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call({
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
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
    return _repository.addMedicineByName(
      token: session.token,
      tradeName: tradeName,
      tradeNameAr: tradeNameAr,
      activeIngredient: activeIngredient,
      price: price,
      quantity: quantity,
      isAvailable: isAvailable,
      imageUrl: imageUrl,
    );
  }
}
