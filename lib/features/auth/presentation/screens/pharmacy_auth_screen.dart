import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/pharmacy_auth_cubit.dart';
import '../cubit/pharmacy_auth_state.dart';
import '../widgets/pharmacy_login_form.dart';

class PharmacyAuthScreen extends StatelessWidget {
  const PharmacyAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PharmacyAuthCubit, PharmacyAuthState>(
          listenWhen: (previous, current) => previous.token == null && current.token != null,
          listener: (context, state) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.pharmacyHomeScreen, (route) => false);
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
                  'مرحباً بعودتك!',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.authScreenTitle,
                ),
                SizedBox(height: 8.h),
                Text(
                  'سجّل دخولك ببيانات صيدليتك للوصول إلى حسابك ومتابعة طلباتك بسهولة.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.authScreenSubtitle,
                ),
                SizedBox(height: 24.h),
                const PharmacyLoginForm(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
