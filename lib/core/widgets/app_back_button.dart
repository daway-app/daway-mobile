import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../theming/app_colors.dart';

/// The small square "back" chip used at the top of sub-screens across
/// features (auth's OTP/terms/privacy screens, patient's account-info and
/// addresses screens, ...) — right-aligned, pointing right to read as "back"
/// in RTL.
class AppBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const AppBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        key: const ValueKey('authBackButton'),
        onTap: onTap,
        child: Container(
          width: 48.w,
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accountIconBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.iconBlueBorder, width: 1.0),
          ),
          child: SvgPicture.asset(
            'assets/icons/back_icon.svg',
            width: 18.w,
            height: 18.h,
          ),
        ),
      ),
    );
  }
}
