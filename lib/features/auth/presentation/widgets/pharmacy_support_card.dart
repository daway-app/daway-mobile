import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Static help card shown under the pharmacy login card, pointing users to
/// support if they can't sign in.
class PharmacySupportCard extends StatelessWidget {
  const PharmacySupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'هل تواجه مشكلة فى تسجيل الدخول؟',
                  style: AppTextStyles.helperText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  'اتصل بالدعم الفنى',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.footerText.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SvgPicture.asset(
            'assets/icons/headset_mic_outlined.svg',
            colorFilter: ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
            width: 24.sp,
            height: 24.sp,
          ),
        ],
      ),
    );
  }
}