import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import 'resend_otp_link.dart';

class OtpVerificationForm extends StatefulWidget {
  const OtpVerificationForm({super.key});

  @override
  State<OtpVerificationForm> createState() => _OtpVerificationFormState();
}

class _OtpVerificationFormState extends State<OtpVerificationForm> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TEMPORARY: SMS delivery is not built yet, so the code the backend
        // returns is shown here. Delete this block once real SMS is live.
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.tempOtp != current.tempOtp,
          builder: (context, state) {
            final code = state.tempOtp;
            if (code == null) return const SizedBox.shrink();
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.permissionIconBg,
                border: Border.all(color: AppColors.iconBlueBorder),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'رمز التحقق (مؤقت): $code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainTeal,
                ),
              ),
            );
          },
        ),
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
          builder: (context, state) {
            final hasError = state.errorMessage != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtpInputField(
                  length: 6,
                  hasError: hasError,
                  onChanged: (value) => setState(() => _otp = value),
                ),
                if (hasError) ...[
                  SizedBox(height: 8.h),
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.authFieldError.copyWith(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            );
          },
        ),

        SizedBox(height: 24.h),

        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.isVerifying != current.isVerifying,
          builder: (context, state) {
            return AppCustomButton(
              text: 'تحقق',
              backgroundColor: AppColors.mainTeal,
              isLoading: state.isVerifying,
              onPressed: () => context.read<PatientAuthCubit>().verifyOtp(_otp),
            );
          },
        ),

        SizedBox(height: 24.h),

        const Center(child: ResendOtpLink()),
      ],
    );
  }
}
