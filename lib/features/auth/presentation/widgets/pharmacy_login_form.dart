import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../cubit/pharmacy_auth_cubit.dart';
import '../cubit/pharmacy_auth_state.dart';

/// Pharmacy ID + password fields shown on [PharmacyAuthScreen].
class PharmacyLoginForm extends StatefulWidget {
  const PharmacyLoginForm({super.key});

  @override
  State<PharmacyLoginForm> createState() => _PharmacyLoginFormState();
}

class _PharmacyLoginFormState extends State<PharmacyLoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<PharmacyAuthCubit>().login(
          pharmacyId: _idController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('معرف الصيدلية (ID)', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _idController,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'معرف الصيدلية مطلوب' : null,
            decoration: _fieldDecoration(),
          ),

          SizedBox(height: 16.h),

          Text('كلمة المرور', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'كلمة المرور مطلوبة' : null,
            decoration: _fieldDecoration().copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          BlocBuilder<PharmacyAuthCubit, PharmacyAuthState>(
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

          BlocBuilder<PharmacyAuthCubit, PharmacyAuthState>(
            buildWhen: (previous, current) => previous.isLoggingIn != current.isLoggingIn,
            builder: (context, state) {
              return AppCustomButton(
                text: 'التالي',
                backgroundColor: AppColors.mainTeal,
                isLoading: state.isLoggingIn,
                onPressed: () => _submit(context),
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
                  Navigator.pushNamed(context, Routes.pharmacySignUpScreen);
                },
                child: Text('أنشئ حساب', style: AppTextStyles.authLinkText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
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
    );
  }
}
