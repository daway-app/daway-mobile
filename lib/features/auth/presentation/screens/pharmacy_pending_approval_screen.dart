import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../widgets/permission_icon_header.dart';

/// Final step of the pharmacy sign-up flow. The create-account API always
/// leaves a new pharmacy pending admin approval — there is no token to log
/// in with yet, so this screen (rather than the home dashboard) is the
/// flow's actual destination; the pharmacy_id/password they chose only
/// work once an admin approves the account and messages them.
class PharmacyPendingApprovalScreen extends StatelessWidget {
  const PharmacyPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                const PermissionIconHeader(
                  icon: Icons.hourglass_top_outlined,
                  title: 'حسابك قيد المراجعة',
                  subtitle:
                      'تم استلام طلب إنشاء حسابك وهو الآن بانتظار موافقة الإدارة. '
                      'سنرسل لك معرّف الصيدلية وكلمة المرور عند تفعيل الحساب.',
                ),
                SizedBox(height: 24.h),
                AppCustomButton(
                  text: 'العودة لتسجيل الدخول',
                  backgroundColor: AppColors.mainTeal,
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.pharmacyAuthScreen, (route) => false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
