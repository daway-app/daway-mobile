import '../../../../core/local_storage/secure_storage_service.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  static const String _tokenKey = 'session_token';
  static const String _accountTypeKey = 'session_account_type';

  final SecureStorageService _storage;

  const SessionRepositoryImpl(this._storage);

  @override
  Future<void> saveSession(UserSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _accountTypeKey, value: session.accountType.name);
  }

  @override
  Future<UserSession?> getSession() async {
    final token = await _storage.read(key: _tokenKey);
    final accountTypeName = await _storage.read(key: _accountTypeKey);
    if (token == null || accountTypeName == null) return null;

    for (final type in AccountType.values) {
      if (type.name == accountTypeName) {
        return UserSession(accountType: type, token: token);
      }
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _accountTypeKey);
  }
}
