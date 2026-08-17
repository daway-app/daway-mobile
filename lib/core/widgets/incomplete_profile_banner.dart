import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Info banner prompting the user to finish setting up their profile —
/// shown on any profile screen (patient, pharmacy, ...) whose data is
/// missing required fields (currently: no location set yet).
class IncompleteProfileBanner extends StatelessWidget {
  final String message;

  const IncompleteProfileBanner({
    super.key,
    this.message = 'بياناتك غير مكتملة، يرجى تعديل حسابك لإكمالها',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.patientIconBackground.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.mainTeal, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.cardDescription.copyWith(color: AppColors.mainTeal),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
