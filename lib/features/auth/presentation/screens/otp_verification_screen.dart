import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/otp_verification_form.dart';
import '../widgets/resend_otp_link.dart';

/// Its own screen (pushed on top of [PatientAuthScreen], sharing the same
/// [PatientAuthCubit] instance) so the phone step and the OTP step are two
/// distinct screens rather than one screen toggling its content.
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) context.read<PatientAuthCubit>().backToPhoneStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: BlocListener<PatientAuthCubit, PatientAuthState>(
            listenWhen: (previous, current) =>
                current.destination != null && previous.destination != current.destination,
            listener: (context, state) {
              final route = state.destination == AuthDestination.profile
                  ? Routes.profileScreen
                  : Routes.patientHomeScreen;
              Navigator.of(context).pushNamedAndRemoveUntil(
                route,
                (route) => false,
                arguments: state.destination == AuthDestination.profile ? state.phone : null,
              );
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16.h),
                  const AppLogo(size: 96),
                  SizedBox(height: 16.h),
                  Text(
                    'ادخل رمز التحقق',
                    style: AppTextStyles.authTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'تم إرسال رمز التحقق إلى رقم جوالك',
                    style: AppTextStyles.authSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  const AppCard(child: OtpVerificationForm()),
                  SizedBox(height: 20.h),
                  const ResendOtpLink(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
