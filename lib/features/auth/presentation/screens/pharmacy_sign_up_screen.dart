import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_logo.dart';
import '../widgets/pharmacy_sign_up_form.dart';

/// Sign-up entry point for pharmacies, reached from [PharmacyAuthScreen]'s
/// "ليس لديك حساب ؟" link. Mirrors [SignUpScreen]'s layout with pharmacy
/// fields instead of patient ones.
class PharmacySignUpScreen extends StatelessWidget {
  const PharmacySignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              const Center(child: AppLogo()),
              SizedBox(height: 32.h),
              Text(
                'أنشئ حسابك',
                textAlign: TextAlign.right,
                style: AppTextStyles.authScreenTitle,
              ),
              SizedBox(height: 8.h),
              Text(
                'ابدأ رحلتك مع دواك واحصل على احتياجاتك من الصيدلية بسهولة.',
                textAlign: TextAlign.right,
                style: AppTextStyles.authScreenSubtitle,
              ),
              SizedBox(height: 24.h),
              const PharmacySignUpForm(),
              SizedBox(height: 24.h),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('لديك حساب بالفعل ؟ ', style: AppTextStyles.authFooterMuted),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed(Routes.pharmacyAuthScreen),
                    child: Text('سجّل دخولك', style: AppTextStyles.authLinkText),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
