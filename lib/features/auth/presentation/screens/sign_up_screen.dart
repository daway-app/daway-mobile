import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/sign_up_form.dart';
import 'otp_verification_screen.dart';

/// Sign-up entry point: collects name/birth date/phone up front, then sends
/// the OTP and pushes [OtpVerificationScreen] sharing this same
/// [PatientAuthCubit] instance — the same merged verify call either logs the
/// patient in or creates their account.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                const Center(child: AppLogo()),
                SizedBox(height: 32.h),
                Text(
                  'أنشئ حسابك',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.authScreenTitle,
                ),
                SizedBox(height: 8.h),
                Text(
                  'ابدأ رحلتك مع دواك واحصل على احتياجاتك من الصيدلية بسهولة.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.authScreenSubtitle,
                ),
                SizedBox(height: 24.h),
                const SignUpForm(),
                SizedBox(height: 50.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل ؟ ', style: AppTextStyles.authFooterMuted),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(Routes.patientAuthScreen),
                      child: Text('سجّل دخولك', style: AppTextStyles.authLinkText),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
