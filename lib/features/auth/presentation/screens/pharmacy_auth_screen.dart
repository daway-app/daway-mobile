import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/pharmacy_auth_cubit.dart';
import '../cubit/pharmacy_auth_state.dart';
import '../widgets/pharmacy_login_form.dart';
import '../widgets/pharmacy_support_card.dart';

class PharmacyAuthScreen extends StatelessWidget {
  const PharmacyAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                const AppLogo(size: 96),
                SizedBox(height: 16.h),
                Text(
                  'دخول الصيدلة',
                  style: AppTextStyles.authTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'يرجى إدخال بيانات اعتماد الصيدلية للمتابعة',
                  style: AppTextStyles.authSubtitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                const AppCard(child: PharmacyLoginForm()),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: const PharmacySupportCard(),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
