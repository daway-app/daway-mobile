import '../../../auth/domain/entities/account_type.dart';

abstract class OnboardingRepository {
  Future<bool> isOnboardingSeen(AccountType accountType);

  Future<void> setOnboardingSeen(AccountType accountType);
}
