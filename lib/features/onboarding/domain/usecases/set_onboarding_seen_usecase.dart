import '../../../auth/domain/entities/account_type.dart';
import '../repositories/onboarding_repository.dart';

class SetOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  const SetOnboardingSeenUseCase(this._repository);

  Future<void> call(AccountType accountType) {
    return _repository.setOnboardingSeen(accountType);
  }
}
