import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';

/// 6-digit OTP entry + "verify" card content shown on [OtpVerificationScreen].
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('رمز التحقق', style: AppTextStyles.inputLabel),
        SizedBox(height: 16.h),
        OtpInputField(length: 6, onChanged: (value) => setState(() => _otp = value)),
        SizedBox(height: 6.h),
        Text(
          'تم إرسال الرمز المكوّن من 6 أرقام إلى جوالك',
          style: AppTextStyles.helperText,
          textAlign: TextAlign.center,
        ),
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
          builder: (context, state) {
            if (state.errorMessage == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                state.errorMessage!,
                style: AppTextStyles.errorText,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        SizedBox(height: 30.h),
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.isVerifying != current.isVerifying,
          builder: (context, state) {
            return AppCustomButton(
              text: 'تحقق',
              trailingIcon: Icons.check,
              height: 48.h,
              isLoading: state.isVerifying,
              onPressed: () => context.read<PatientAuthCubit>().verifyOtp(_otp),
            );
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
