import '../../../../core/local_storage/secure_storage_service.dart';
import '../../../auth/domain/entities/account_type.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SecureStorageService _storage;

  const OnboardingRepositoryImpl(this._storage);

  String _keyFor(AccountType accountType) => 'onboarding_seen_${accountType.name}';

  @override
  Future<bool> isOnboardingSeen(AccountType accountType) async {
    final value = await _storage.read(key: _keyFor(accountType));
    return value == 'true';
  }

  @override
  Future<void> setOnboardingSeen(AccountType accountType) {
    return _storage.write(key: _keyFor(accountType), value: 'true');
  }
}
