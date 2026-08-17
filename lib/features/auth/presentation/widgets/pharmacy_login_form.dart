import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/pharmacy_auth_cubit.dart';
import '../cubit/pharmacy_auth_state.dart';

/// Pharmacy ID + password card content shown on [PharmacyAuthScreen].
class PharmacyLoginForm extends StatefulWidget {
  const PharmacyLoginForm({super.key});

  @override
  State<PharmacyLoginForm> createState() => _PharmacyLoginFormState();
}

class _PharmacyLoginFormState extends State<PharmacyLoginForm> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('معرف الصيدلية', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        SizedBox(
          height: 48.h,
          child: AppTextField(
            controller: _idController,
            hintText: 'أدخل رقم المعرف الخاص بك',
            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.grey, size: 20.sp),
          ),
        ),
        SizedBox(height: 16.h),
        Text('كلمة المرور', style: AppTextStyles.inputLabel),
        SizedBox(height: 8.h),
        SizedBox(
          height: 48.h,
          child: AppTextField(
            controller: _passwordController,
            hintText: 'أدخل كلمة المرور',
            obscureText: _obscurePassword,
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 20.sp),
            icon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.grey,
                size: 20.sp,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        BlocBuilder<PharmacyAuthCubit, PharmacyAuthState>(
          buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
          builder: (context, state) {
            if (state.errorMessage == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                state.errorMessage!,
                style: AppTextStyles.errorText,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        BlocBuilder<PharmacyAuthCubit, PharmacyAuthState>(
          buildWhen: (previous, current) => previous.isLoggingIn != current.isLoggingIn,
          builder: (context, state) {
            return AppCustomButton(
              text: 'تسجيل الدخول',
              trailingIcon: Icons.login,
              height: 48.h,
              isLoading: state.isLoggingIn,
              onPressed: () => context.read<PharmacyAuthCubit>().login(
                    pharmacyId: _idController.text.trim(),
                    password: _passwordController.text,
                  ),
            );
          },
        ),
      ],
    );
  }
}
