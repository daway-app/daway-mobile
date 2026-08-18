import '../repositories/onboarding_repository.dart';

class GetOnboardingSeenUseCase {
  final OnboardingRepository _repository;

  const GetOnboardingSeenUseCase(this._repository);

  Future<bool> call() {
    return _repository.isOnboardingSeen();
  }
}
