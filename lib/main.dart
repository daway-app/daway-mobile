import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupGetIt();
  runApp(DawayApp(appRouter: AppRouter()));
}