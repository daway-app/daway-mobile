import '../../features/auth/domain/entities/account_type.dart';
import '../../features/auth/domain/usecases/get_session_usecase.dart';
import 'routes.dart';

class InitialRouteResolver {
  final GetSessionUseCase _getSessionUseCase;

  const InitialRouteResolver(this._getSessionUseCase);

  Future<String> resolve() async {
    try {
      final session = await _getSessionUseCase();
      return switch (session?.accountType) {
        AccountType.patient => Routes.patientHomeScreen,
        AccountType.pharmacy => Routes.pharmacyHomeScreen,
        null => Routes.accountTypeScreen,
      };
    } catch (_) {
      // Session storage failed to read — fail closed to account selection
      // rather than crashing app startup.
      return Routes.accountTypeScreen;
    }
  }
}
