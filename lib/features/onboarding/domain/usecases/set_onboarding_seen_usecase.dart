import '../repositories/onboarding_repository.dart';

class SetOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  const SetOnboardingSeenUseCase(this._repository);

  Future<void> call() {
    return _repository.setOnboardingSeen();
  }
}
