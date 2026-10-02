import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Section title + "عرض الكل" chip, shared by the patient home's sections and
/// the pharmacy home's orders section.
///
/// By default the title, the chip's label and its chevron have the look of the
/// patient home; a section with a look of its own passes [titleStyle],
/// [actionStyle], [chevronColor] and [chevronSize].
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onActionTap;
  final String actionLabel;
  final TextStyle? titleStyle;
  final TextStyle? actionStyle;
  final Color? chevronColor;
  final double chevronSize;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onActionTap,
    this.actionLabel = 'عرض الكل',
    this.titleStyle,
    this.actionStyle,
    this.chevronColor,
    this.chevronSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final chevronTint = chevronColor;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: titleStyle ?? AppTextStyles.homeSectionTitle,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onActionTap,
          child: Container(
            constraints: BoxConstraints(minWidth: 107.w, minHeight: 32.h),
            // 3 (not 4) so a 24px chevron still fits the chip's 32px height.
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.homeChipBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(actionLabel, style: actionStyle ?? AppTextStyles.homeSectionChip),
                SizedBox(width: 4.w),
                SvgPicture.asset(
                  'assets/icons/arrow_icon.svg',
                  width: chevronSize.w,
                  height: chevronSize.w,
                  colorFilter: chevronTint == null
                      ? null
                      : ColorFilter.mode(chevronTint, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
