import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/otp_verification_form.dart';
import 'location_permission_screen.dart';
import 'notifications_permission_screen.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) context.read<PatientAuthCubit>().backToPhoneStep();
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<PatientAuthCubit, PatientAuthState>(
            listenWhen: (previous, current) =>
                (current.needsLocation && !previous.needsLocation) ||
                (current.destination != null && previous.destination != current.destination),
            listener: (context, state) {
              final cubit = context.read<PatientAuthCubit>();
              if (state.needsLocation) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const LocationPermissionScreen(),
                    ),
                  ),
                );
              } else if (state.destination == AuthDestination.notifications) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const NotificationsPermissionScreen(),
                    ),
                  ),
                );
              } else if (state.destination == AuthDestination.home) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.patientHomeScreen, (route) => false);
              }
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                  AppBackButton(onTap: () => Navigator.of(context).pop()),
                  SizedBox(height: 32.h),

                  Text(
                    'خطوة أخيرة!',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.authScreenTitle,
                  ),
                  SizedBox(height: 8.h),

                  BlocSelector<PatientAuthCubit, PatientAuthState, String>(
                    selector: (state) => state.phone,
                    builder: (context, phone) => Text(
                      'أدخل رمز التحقق المرسل إلى رقم هاتفك\n للمتابعة $phone',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.authScreenSubtitle,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  const OtpVerificationForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}