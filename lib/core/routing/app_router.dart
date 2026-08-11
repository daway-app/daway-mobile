import 'package:daway_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/patient_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_auth_screen.dart';
import 'package:daway_app/features/patient_home/presentation/screens/patient_home_screen.dart';
import 'package:daway_app/features/pharmacy_home/presentation/screens/pharmacy_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/account_type_cubit.dart';
import '../../features/auth/presentation/cubit/logout_cubit.dart';
import '../../features/auth/presentation/cubit/patient_auth_cubit.dart';
import '../../features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.accountTypeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<AccountTypeCubit>(),
            child: const AccountTypeScreen(),
          ),
        );

      case Routes.patientAuthScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PatientAuthCubit>(),
            child: const PatientAuthScreen(),
          ),
        );

      case Routes.pharmacyAuthScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PharmacyAuthCubit>(),
            child: const PharmacyAuthScreen(),
          ),
        );

      case Routes.patientHomeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LogoutCubit>(),
            child: const PatientHomeScreen(),
          ),
        );

      case Routes.pharmacyHomeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LogoutCubit>(),
            child: const PharmacyHomeScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
