import '../../../auth/domain/entities/account_type.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  const GetOnboardingSeenUseCase(this._repository);

  Future<bool> call(AccountType accountType) {
    return _repository.isOnboardingSeen(accountType);
  }
}
