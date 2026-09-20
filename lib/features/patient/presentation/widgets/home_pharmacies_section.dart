import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// "الصيدليات" section — a single discovery card (no nearby-pharmacies API
/// yet, so it just hands off to [onDiscoverTap]) plus its plain section
/// title. Unlike [HomeCategoriesSection], there's no "عرض الكل" chip here.
class HomePharmaciesSection extends StatelessWidget {
  final VoidCallback onDiscoverTap;

  const HomePharmaciesSection({super.key, required this.onDiscoverTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onDiscoverTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.iconBlueBorder),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.iconBlueBorder),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SvgPicture.asset('assets/icons/map_icon.svg', width: 16.w, height: 16.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('صيدليات', style: AppTextStyles.homePharmacyCardTitle),
                      SizedBox(height: 4.h),
                      Text('اكتشف الصيدليات القريبة منك', style: AppTextStyles.homePharmacyCardSubtitle),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                SvgPicture.asset('assets/icons/arrow_icon.svg', width: 16.w, height: 16.w),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
