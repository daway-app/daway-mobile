import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/digits_only_formatter.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';

class PatientPhoneForm extends StatefulWidget {
  const PatientPhoneForm({super.key});

  @override
  State<PatientPhoneForm> createState() => _PatientPhoneFormState();
}

class _PatientPhoneFormState extends State<PatientPhoneForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'رقم هاتفك',
            textAlign: TextAlign.right,
            style: AppTextStyles.authFieldLabel,
          ),

          SizedBox(height: 8.h),

          BlocBuilder<PatientAuthCubit, PatientAuthState>(
            buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
            builder: (context, state) {
              return TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                inputFormatters: [DigitsOnlyFormatter()],
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.authTextPrimary,
                ),
                onChanged: (value) {
                  context.read<PatientAuthCubit>().phoneChanged(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.authInputBorder, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.authError, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: AppColors.authError, width: 1.5),
                  ),
                  errorStyle: AppTextStyles.authFieldError,
                ),
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
                  style: AppTextStyles.authFieldError,
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          BlocBuilder<PatientAuthCubit, PatientAuthState>(
            buildWhen: (previous, current) => previous.isSendingOtp != current.isSendingOtp,
            builder: (context, state) {
              return AppCustomButton(
                text: 'التالي',
                backgroundColor: AppColors.primaryTeal,
                isLoading: state.isSendingOtp,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<PatientAuthCubit>().sendOtp();
                  }
                },
              );
            },
          ),

          SizedBox(height: 32.h),

          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text('ليس لديك حساب ؟ ', style: AppTextStyles.authFooterMuted),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.signUpScreen);
                },
                child: Text('أنشئ حساب', style: AppTextStyles.authLinkText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
