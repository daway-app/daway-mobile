import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';

/// Shown right after a successful logout, in place of jumping the user
/// straight back to [Routes.accountTypeScreen] — pushed with
/// `pushNamedAndRemoveUntil` (same as the old direct navigation) so the
/// logged-out session isn't left reachable via back, and its own button
/// continues on to account-type the same way.
class LogoutFarewellScreen extends StatelessWidget {
  const LogoutFarewellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The illustration runs edge-to-edge under the status bar in the
      // design (its background continues the app's own gradient) — only the
      // content below it, and the button's bottom clearance, respect safe
      // area.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/logout_farewell.png',
            width: double.infinity,
            height: 439.h,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 76.h),
                  Text(
                    'سوف نفتقدك',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.farewellTitle,
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'يمكنك العودة دائمًا متى احتجت إلينا.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.farewellSubtitle,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 37.h),
                    child: AppCustomButton(
                      text: 'العودة للتطبيق',
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.accountTypeScreen, (route) => false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
