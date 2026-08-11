import '../entities/user_session.dart';
import '../repositories/session_repository.dart';

class GetSessionUseCase {
  final SessionRepository _repository;

  const GetSessionUseCase(this._repository);

  Future<UserSession?> call() {
    return _repository.getSession();
  }
}
