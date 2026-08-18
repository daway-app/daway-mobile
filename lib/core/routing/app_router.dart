import 'package:daway_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:daway_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/patient_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_auth_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/complete_profile_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/location_picker_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_dashboard_shell_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_dashboard_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/account_type_cubit.dart';
import '../../features/auth/presentation/cubit/logout_cubit.dart';
import '../../features/auth/presentation/cubit/patient_auth_cubit.dart';
import '../../features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import '../models/picked_location.dart';
import '../../features/patient/presentation/cubit/complete_profile_cubit.dart';
import '../../features/patient/presentation/cubit/location_picker_cubit.dart';
import '../constants/app_constants.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

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
            child: const PatientDashboardShellScreen(),
          ),
        );

      case Routes.pharmacyHomeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LogoutCubit>(),
            child: const PharmacyDashboardShellScreen(),
          ),
        );

      case Routes.profileScreen:
        final phone = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CompleteProfileCubit>(param1: phone),
            child: const CompleteProfileScreen(),
          ),
        );

      case Routes.locationPickerScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<PickedLocation?>(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LocationPickerCubit>(
              param1: LocationPickerParams(
                initialLatitude:
                    args?['latitude'] as double? ?? AppConstants.defaultMapLatitude,
                initialLongitude:
                    args?['longitude'] as double? ?? AppConstants.defaultMapLongitude,
                initialAddress: args?['address'] as String?,
              ),
            ),
            child: const LocationPickerScreen(),
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
