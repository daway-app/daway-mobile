import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../repositories/favorites_repository.dart';

class AddFavoriteMedicineUseCase {
  final FavoritesRepository _repository;
  final SessionRepository _sessionRepository;

  const AddFavoriteMedicineUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<void>> call(int medicineId) async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.addFavoriteMedicine(token: session.token, medicineId: medicineId);
  }
}
