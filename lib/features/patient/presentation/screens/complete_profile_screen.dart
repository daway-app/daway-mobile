import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/complete_profile_cubit.dart';
import '../cubit/complete_profile_state.dart';
import '../widgets/complete_profile_form.dart';

/// Shown only right after a patient's first successful login (see
/// [PatientAuthCubit.verifyOtp] / `AuthDestination.profile`), before they
/// ever reach [Routes.patientHomeScreen].
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<CompleteProfileCubit, CompleteProfileState>(
            listener: (context, state) {
              switch (state) {
                case CompleteProfileSuccess():
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.patientHomeScreen, (route) => false);
                case CompleteProfileFailure(:final message):
                  AppSnackbar.show(context, message);
                case CompleteProfileInitial():
                case CompleteProfileLoading():
              }
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'أكمل بيانات حسابك',
                    style: AppTextStyles.authTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'نحتاج بعض المعلومات لإتمام إعداد حسابك',
                    style: AppTextStyles.authSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  const AppCard(child: CompleteProfileForm()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
