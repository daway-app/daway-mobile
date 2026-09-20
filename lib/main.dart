import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/routing/app_router.dart';
import 'core/routing/initial_route_resolver.dart';
import 'core/services/notification_service.dart';
import 'features/auth/domain/usecases/get_session_usecase.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env');
  await setupGetIt();
  await NotificationService.init();

  final initialRoute =
      await InitialRouteResolver(getIt<GetSessionUseCase>()).resolve();

  runApp(DawayApp(appRouter: AppRouter(), initialRoute: initialRoute));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
