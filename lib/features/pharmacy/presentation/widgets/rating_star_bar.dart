import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';

/// One row of the ratings summary's star breakdown — [count] out of
/// [maxCount] (the largest bucket, so the busiest row always fills the bar).
class RatingStarBar extends StatelessWidget {
  final int stars;
  final int count;
  final int maxCount;

  const RatingStarBar({
    super.key,
    required this.stars,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 46.w,
            child: Text(
              stars == 1 ? '1 نجمة' : '$stars نجوم',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8.h,
                backgroundColor: AppColors.lightGrey,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 26.w,
            child: Text(
              '$count',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
          ),
        ],
      ),
    );
  }
}
