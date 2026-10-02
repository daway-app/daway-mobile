import 'package:daway_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/logout_farewell_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/patient_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_auth_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/pharmacy_sign_up_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/all_categories_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/category_medicines_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/medicine_detail_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/medicine_reminders_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_cart_screen.dart';
import 'package:daway_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_pharmacies_map_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/rate_experience_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/location_picker_screen.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_dashboard_shell_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/add_medicine_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/edit_medicine_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_alternatives_entry_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_alternatives_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_dashboard_shell_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_notifications_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_ratings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/account_type_cubit.dart';
import '../../features/auth/presentation/cubit/logout_cubit.dart';
import '../../features/auth/presentation/cubit/patient_auth_cubit.dart';
import '../../features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import '../../features/auth/presentation/cubit/pharmacy_sign_up_cubit.dart';
import '../models/picked_location.dart';
import '../../features/patient/domain/entities/category.dart';
import '../../features/patient/presentation/cubit/location_picker_cubit.dart';
import '../../features/pharmacy/domain/entities/medicine.dart';
import '../../features/pharmacy/presentation/cubit/add_medicine_cubit.dart';
import '../../features/pharmacy/presentation/cubit/edit_medicine_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_alternatives_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_alternatives_medicines_cubit.dart';
import '../../features/pharmacy/presentation/cubit/notifications_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_ratings_cubit.dart';
import '../constants/app_constants.dart';
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

      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PatientAuthCubit>(),
            child: const SignUpScreen(),
          ),
        );

      case Routes.pharmacySignUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PharmacySignUpCubit>(),
            child: const PharmacySignUpScreen(),
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

      case Routes.addPharmacyMedicineScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<AddMedicineCubit>(),
            child: const AddMedicineScreen(),
          ),
        );

      case Routes.editPharmacyMedicineScreen:
        final medicine = settings.arguments as Medicine;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<EditMedicineCubit>(param1: medicine),
            child: EditMedicineScreen(medicine: medicine),
          ),
        );

      case Routes.pharmacyAlternativesEntryScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PharmacyAlternativesMedicinesCubit>(),
            child: const PharmacyAlternativesEntryScreen(),
          ),
        );

      case Routes.pharmacyAlternativesScreen:
        final medicine = settings.arguments as Medicine;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                getIt<PharmacyAlternativesCubit>(param1: medicine),
            child: const PharmacyAlternativesScreen(),
          ),
        );

      case Routes.pharmacyRatingsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<PharmacyRatingsCubit>(),
            child: const PharmacyRatingsScreen(),
          ),
        );

      case Routes.pharmacyNotificationsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<NotificationsCubit>(),
            child: const PharmacyNotificationsScreen(),
          ),
        );

      case Routes.allCategoriesScreen:
        return MaterialPageRoute(
          builder: (_) => const AllCategoriesScreen(),
        );

      case Routes.categoryMedicinesScreen:
        final category = settings.arguments as Category;
        return MaterialPageRoute(
          builder: (_) => CategoryMedicinesScreen(category: category),
        );

      case Routes.medicineRemindersScreen:
        return MaterialPageRoute(
          builder: (_) => const MedicineRemindersScreen(),
        );

      case Routes.medicineDetailScreen:
        final medicineId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicineId: medicineId),
        );

      case Routes.patientCartScreen:
        return MaterialPageRoute(
          builder: (_) => const PatientCartScreen(),
        );

      case Routes.patientPharmaciesMapScreen:
        return MaterialPageRoute(
          builder: (_) => const PatientPharmaciesMapScreen(),
        );

      case Routes.logoutFarewellScreen:
        return MaterialPageRoute(
          builder: (_) => const LogoutFarewellScreen(),
        );

      case Routes.rateExperienceScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RateExperienceScreen(
            pharmacyId: args['pharmacyId'] as int,
            pharmacyName: args['pharmacyName'] as String,
          ),
        );

      case Routes.chatScreen:
        final chatArgs = ChatArgs.fromMap(settings.arguments as Map<String, dynamic>);
        return MaterialPageRoute(
          builder: (_) => ChatScreen(args: chatArgs),
        );

      case Routes.locationPickerScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<PickedLocation?>(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LocationPickerCubit>(
              param1: LocationPickerParams(
                initialLatitude:
                    args?['latitude'] as double? ??
                    AppConstants.defaultMapLatitude,
                initialLongitude:
                    args?['longitude'] as double? ??
                    AppConstants.defaultMapLongitude,
                initialAddress: args?['address'] as String?,
              ),
            ),
            child: const LocationPickerScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
