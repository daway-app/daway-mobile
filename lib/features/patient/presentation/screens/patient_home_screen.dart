import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout_state.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/patient_profile_cubit.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_image_search_card.dart';
import '../widgets/home_pharmacies_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/patient_dashboard_tab_scope.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PatientProfileCubit>()),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()),
      ],
      child: const _PatientHomeView(),
    );
  }
}

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView();

  void _comingSoon(BuildContext context) => AppSnackbar.show(context, 'قريباً');

  void _goToSearchTab(BuildContext context) {
    PatientDashboardTabScope.maybeOf(context)?.switchToTab(PatientDashboardTab.search);
  }

  void _goToScanTab(BuildContext context) {
    PatientDashboardTabScope.maybeOf(context)?.switchToTab(PatientDashboardTab.scan);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutCubit, LogoutState>(
      listenWhen: (previous, current) => !previous.isLoggedOut && current.isLoggedOut,
      listener: (context, state) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.accountTypeScreen, (route) => false);
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                onCartTap: () => _comingSoon(context),
                onNotificationsTap: () => _comingSoon(context),
                onLocationTap: () => _comingSoon(context),
              ),
              SizedBox(height: 24.h),
              HomeSearchBar(onTap: () => _goToSearchTab(context)),
              SizedBox(height: 24.h),
              HomeImageSearchCard(onSearchTap: () => _goToScanTab(context)),
              SizedBox(height: 24.h),
              HomeCategoriesSection(
                onViewAllTap: () => Navigator.of(context).pushNamed(Routes.allCategoriesScreen),
                onCategoryTap: (category) => Navigator.of(context)
                    .pushNamed(Routes.categoryMedicinesScreen, arguments: category),
              ),
              SizedBox(height: 24.h),
              HomePharmaciesSection(onDiscoverTap: () => _comingSoon(context)),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
