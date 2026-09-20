import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Section title + "عرض الكل" chip, shared by the categories and pharmacies
/// sections on [PatientHomeScreen].
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAllTap;

  const HomeSectionHeader({super.key, required this.title, required this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, textAlign: TextAlign.right, style: AppTextStyles.homeSectionTitle),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onViewAllTap,
          child: Container(
            constraints: BoxConstraints(minWidth: 107.w, minHeight: 32.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.homeChipBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('عرض الكل', style: AppTextStyles.homeSectionChip),
                SizedBox(width: 4.w),
                SvgPicture.asset('assets/icons/arrow_icon.svg', width: 16.w, height: 16.w),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
