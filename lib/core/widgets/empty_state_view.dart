import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// The illustrated "nothing here yet" block shared by the patient list
/// screens (orders, saved medicines, reminders, notifications, addresses): an
/// illustration, a bold title, an optional supporting line, and an optional
/// content-sized call-to-action button.
class EmptyStateView extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  /// Space above the illustration, below whatever header precedes this view.
  final double topSpacing;

  const EmptyStateView({
    super.key,
    required this.imageAsset,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.topSpacing = 48,
  }) : assert(
          (actionLabel == null) == (onActionTap == null),
          'actionLabel and onActionTap must be given together',
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: topSpacing.h),
          Image.asset(imageAsset, width: 208.w, height: 208.h),
          SizedBox(height: 24.h),
          // Capped at the illustration's width so a long title wraps under
          // it (as in the design) instead of running wider than the image.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 208.w),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyStateTitle,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 16.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyStateSubtitle,
            ),
          ],
          if (actionLabel != null) ...[
            SizedBox(height: 16.h),
            // No `alignment` on this Container: with a child it would expand
            // to fill the available width instead of shrink-wrapping.
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                height: 33.h,
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.permissionIconBg,
                  border: Border.all(color: AppColors.iconBlueBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(actionLabel!, style: AppTextStyles.emptyStateAction),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
