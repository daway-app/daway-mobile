import '../entities/account_type.dart';
import '../entities/user_session.dart';
import '../repositories/session_repository.dart';

class SaveSessionUseCase {
  final SessionRepository _repository;

  const SaveSessionUseCase(this._repository);

  Future<void> call({required AccountType accountType, required String token}) {
    return _repository.saveSession(
      UserSession(accountType: accountType, token: token),
    );
  }
}
