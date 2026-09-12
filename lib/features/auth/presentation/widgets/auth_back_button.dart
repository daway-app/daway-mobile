import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';

/// The small square "back" chip used at the top of the OTP/terms/privacy
/// screens — right-aligned, pointing right to read as "back" in RTL.
class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const AuthBackButton({super.key, required this.onTap});

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
