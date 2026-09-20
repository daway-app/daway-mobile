import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// "ابحث بالصورة" promo card — hands off to the scan tab. Laid out as a Row
/// (text column on the right, illustration on the left) rather than a Stack
/// overlay, so the 16px text↔image gap and the bottom-pinned button are
/// exact instead of incidental.
class HomeImageSearchCard extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeImageSearchCard({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.accountIconBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.iconBlueBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ابحث بالصورة',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.homeImageSearchTitle,
                ),
                SizedBox(height: 8.h),
                Text(
                  'ارفع روشتتك أو صوّر علبة الدواء للعثور عليه بسهولة',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.homeImageSearchSubtitle,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.iconBlueBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/scan_icon.svg',
                            width: 16.w,
                            height: 16.w,
                            colorFilter: const ColorFilter.mode(
                              AppColors.mainTeal,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text('ابحث الان', style: AppTextStyles.homeImageSearchButton),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/images/banner_image.png', width: 150.w, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
