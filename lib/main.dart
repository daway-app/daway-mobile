import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'features/auth/domain/entities/account_type.dart';
import 'features/auth/domain/usecases/get_session_usecase.dart';
import 'features/onboarding/domain/usecases/get_onboarding_seen_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await setupGetIt();

  final session = await getIt<GetSessionUseCase>()();
  final onboardingSeen = await getIt<GetOnboardingSeenUseCase>()();
  final initialRoute = switch (session?.accountType) {
    AccountType.patient => Routes.patientHomeScreen,
    AccountType.pharmacy => Routes.pharmacyHomeScreen,
    null => onboardingSeen ? Routes.accountTypeScreen : Routes.onboardingScreen,
  };

  runApp(DawayApp(appRouter: AppRouter(), initialRoute: initialRoute));
}