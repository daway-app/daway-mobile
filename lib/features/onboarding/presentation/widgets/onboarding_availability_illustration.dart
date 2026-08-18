import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';

class OnboardingAvailabilityIllustration extends StatelessWidget {
  const OnboardingAvailabilityIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260.w,
      height: 260.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260.w,
            height: 260.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mainTeal.withValues(alpha: 0.15),
            ),
          ),
          Container(
            width: 215.w,
            height: 215.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightTeal.withValues(alpha: 0.35),
            ),
          ),
          Container(
            width: 170.w,
            height: 170.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
          ),
          Container(
            width: 118.w,
            height: 148.w,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_liquid_outlined,
                  color: AppColors.mainTeal,
                  size: 34.sp,
                ),
                SizedBox(height: 14.h),
                Container(
                  height: 5.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 5.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6.h,
            right: 6.w,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTeal,
              ),
              child: Icon(Icons.search, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}
