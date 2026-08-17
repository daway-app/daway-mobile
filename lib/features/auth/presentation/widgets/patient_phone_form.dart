import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';

/// Phone number + terms + "send verification code" card content shown on
/// the phone step of [PatientAuthScreen].
class PatientPhoneForm extends StatefulWidget {
  const PatientPhoneForm({super.key});

  @override
  State<PatientPhoneForm> createState() => _PatientPhoneFormState();
}

class _PatientPhoneFormState extends State<PatientPhoneForm> {
  late final TextEditingController _phoneController;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _termsRecognizer = TapGestureRecognizer()..onTap = () {};
    _privacyRecognizer = TapGestureRecognizer()..onTap = () {};
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('رقم الجوال', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        SizedBox(
          height: 48.h,
          child: AppTextField(
            controller: _phoneController,
            hintText: '05xxxxxxxx',
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone_android_outlined, color: AppColors.grey, size: 20.sp),
            onChanged: (value) => context.read<PatientAuthCubit>().phoneChanged(value),
          ),
        ),
        SizedBox(height: 16.h),
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.agreedToTerms != current.agreedToTerms,
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: state.agreedToTerms,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (value) =>
                      context.read<PatientAuthCubit>().termsToggled(value ?? false),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: AppTextStyles.helperText,
                      children: [
                        const TextSpan(text: 'بالمتابعة، أنت توافق على '),
                        TextSpan(
                          text: 'شروط الخدمة',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        const TextSpan(text: ' و '),
                        TextSpan(
                          text: 'سياسة الخصوصية',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                        const TextSpan(text: ' الخاصة بتطبيق دوائي.'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        SizedBox(height: 20.h),
        BlocBuilder<PatientAuthCubit, PatientAuthState>(
          buildWhen: (previous, current) => previous.isSendingOtp != current.isSendingOtp,
          builder: (context, state) {
            return AppCustomButton(
              text: 'إرسال رمز التحقق',
              trailingIcon: Icons.arrow_back,
              height: 48.h,
              isLoading: state.isSendingOtp,
              onPressed: () => context.read<PatientAuthCubit>().sendOtp(),
            );
          },
        ),
      ],
    );
  }
}
