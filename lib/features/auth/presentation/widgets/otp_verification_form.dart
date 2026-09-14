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
