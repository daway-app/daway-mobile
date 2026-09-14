import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';

/// Small pill button labelled "تعديل" — used on the account-info and
/// addresses screens to enter edit mode for a field or a saved address.
class EditChip extends StatelessWidget {
  final VoidCallback onTap;

  const EditChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.permissionIconBg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/edit_icon.svg',
              width: 14.w,
              height: 14.w,
              colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
            ),
            SizedBox(width: 4.w),
            Text(
              'تعديل',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.mainTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
