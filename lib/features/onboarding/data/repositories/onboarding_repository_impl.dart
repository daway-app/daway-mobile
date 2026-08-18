import '../../../../core/local_storage/secure_storage_service.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _onboardingSeenKey = 'onboarding_seen';

  final SecureStorageService _storage;

  const OnboardingRepositoryImpl(this._storage);

  @override
  Future<bool> isOnboardingSeen() async {
    final value = await _storage.read(key: _onboardingSeenKey);
    return value == 'true';
  }

  @override
  Future<void> setOnboardingSeen() {
    return _storage.write(key: _onboardingSeenKey, value: 'true');
  }
}
