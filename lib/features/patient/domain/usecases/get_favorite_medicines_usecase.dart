import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/favorite_medicine.dart';
import '../repositories/favorites_repository.dart';

class GetFavoriteMedicinesUseCase {
  final FavoritesRepository _repository;
  final SessionRepository _sessionRepository;

  const GetFavoriteMedicinesUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<FavoriteMedicine>>> call() async {
    final session = await _sessionRepository.getSession();
    if (session == null) {
      return const ApiError(
        ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
      );
    }
    return _repository.getFavoriteMedicines(token: session.token);
  }
}
