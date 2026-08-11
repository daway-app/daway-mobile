import 'package:daway_app/core/local_storage/secure_storage_service.dart';
import 'package:daway_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}

void main() {
  late _FakeSecureStorageService storage;
  late SessionRepositoryImpl repository;

  setUp(() {
    storage = _FakeSecureStorageService();
    repository = SessionRepositoryImpl(storage);
  });

  test('returns null when nothing was saved', () async {
    expect(await repository.getSession(), isNull);
  });

  test('round-trips a saved session', () async {
    await repository.saveSession(
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-123'),
    );

    final session = await repository.getSession();

    expect(session?.accountType, AccountType.pharmacy);
    expect(session?.token, 'tok-123');
  });

  test('returns null again after clearing', () async {
    await repository.saveSession(
      const UserSession(accountType: AccountType.patient, token: 'tok-456'),
    );

    await repository.clearSession();

    expect(await repository.getSession(), isNull);
  });
}
