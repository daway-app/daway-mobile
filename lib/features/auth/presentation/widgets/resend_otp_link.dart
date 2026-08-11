import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';

/// Helper link under the OTP card to resend the verification code.
class ResendOtpLink extends StatelessWidget {
  const ResendOtpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientAuthCubit, PatientAuthState>(
      buildWhen: (previous, current) => previous.isSendingOtp != current.isSendingOtp,
      builder: (context, state) {
        return GestureDetector(
          onTap: state.isSendingOtp ? null : () => context.read<PatientAuthCubit>().sendOtp(),
          child: state.isSendingOtp
              ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryTeal,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16.sp, color: AppColors.primaryTeal),
                    SizedBox(width: 4.w),
                    Text(
                      'إعادة إرسال الرمز',
                      style: AppTextStyles.footerText.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
