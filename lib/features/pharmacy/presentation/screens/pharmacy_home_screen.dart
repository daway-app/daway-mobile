import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout_state.dart';
import '../widgets/pharmacy_side_menu.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const PharmacySideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('الصفحة الرئيسية', style: AppTextStyles.screenTitle),
      ),
      body: BlocListener<LogoutCubit, LogoutState>(
        listenWhen: (previous, current) => !previous.isLoggedOut && current.isLoggedOut,
        listener: (context, state) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.accountTypeScreen, (route) => false);
        },
        child: Center(
          child: Text(
            'أهلاً بك',
            style: AppTextStyles.authSubtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
