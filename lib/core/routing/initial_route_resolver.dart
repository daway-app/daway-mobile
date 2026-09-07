import '../../features/auth/domain/entities/account_type.dart';
import '../../features/auth/domain/usecases/get_session_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_seen_usecase.dart';
import 'routes.dart';

class InitialRouteResolver {
  final GetSessionUseCase _getSessionUseCase;
  final GetOnboardingSeenUseCase _getOnboardingSeenUseCase;

  const InitialRouteResolver(
    this._getSessionUseCase,
    this._getOnboardingSeenUseCase,
  );

  Future<String> resolve() async {
    try {
      final sessionFuture = _getSessionUseCase();
      final onboardingSeenFuture = _getOnboardingSeenUseCase();
      final session = await sessionFuture;
      final onboardingSeen = await onboardingSeenFuture;
      return switch (session?.accountType) {
        AccountType.patient => Routes.patientHomeScreen,
        AccountType.pharmacy => Routes.pharmacyHomeScreen,
        null =>
          onboardingSeen ? Routes.accountTypeScreen : Routes.onboardingScreen,
      };
    } catch (_) {
      // Session/onboarding storage failed to read — fail closed to
      // onboarding rather than crashing app startup.
      return Routes.onboardingScreen;
    }
  }
}
