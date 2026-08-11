import '../entities/user_session.dart';

abstract class SessionRepository {
  Future<void> saveSession(UserSession session);

  Future<UserSession?> getSession();

  Future<void> clearSession();
}
