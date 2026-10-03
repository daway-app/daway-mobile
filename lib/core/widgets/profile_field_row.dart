import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import 'edit_chip.dart';

/// A bordered row on an account-info screen: the field's value ([child]) on
/// the right and a "تعديل" chip on the left.
class ProfileFieldRow extends StatelessWidget {
  final Widget child;
  final VoidCallback onEditTap;

  const ProfileFieldRow({
    super.key,
    required this.child,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          SizedBox(width: 8.w),
          EditChip(onTap: onEditTap),
        ],
      ),
    );
  }
}
