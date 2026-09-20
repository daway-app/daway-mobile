import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Read-only search field on [PatientHomeScreen] — tapping it hands off to
/// the real search tab instead of typing inline.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Search_icon.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(
                AppColors.mainTeal,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'ابحث عن دواء او صيدلية',
                textAlign: TextAlign.right,
                style: AppTextStyles.homeSearchHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
