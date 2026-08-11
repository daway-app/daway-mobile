import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/patient_phone_form.dart';
import '../widgets/pharmacy_login_link.dart';
import 'otp_verification_screen.dart';

/// Merged screen for patient sign-in and sign-up: a single phone field and
/// "send verification code" button. Whether the number is new or already
/// registered is never revealed here — that only surfaces after the OTP is
/// verified, on [OtpVerificationScreen].
class PatientAuthScreen extends StatelessWidget {
  const PatientAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<PatientAuthCubit, PatientAuthState>(
          listenWhen: (previous, current) => !previous.otpSent && current.otpSent,
          listener: (context, state) {
            final cubit = context.read<PatientAuthCubit>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const OtpVerificationScreen(),
                ),
              ),
            );
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 88.h),
                const AppLogo(size: 96),
                SizedBox(height: 16.h),
                Text(
                  'أهلاً بك في دوائي',
                  style: AppTextStyles.authTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل رقم جوالك للمتابعة',
                  style: AppTextStyles.authSubtitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: const PatientPhoneForm(),
                ),
                SizedBox(height: 20.h),
                const PharmacyLoginLink(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
