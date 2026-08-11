import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Best-effort remote logout (revokes the token server-side) followed by an
/// unconditional local session clear — the local session must end even if
/// the device is offline or the remote call fails.
class LogoutUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  const LogoutUseCase(this._authRepository, this._sessionRepository);

  Future<void> call() async {
    final session = await _sessionRepository.getSession();
    if (session != null) {
      await _authRepository.logout(token: session.token);
    }
    await _sessionRepository.clearSession();
  }
}
