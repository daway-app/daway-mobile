import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The card of a medicines results grid (a category's medicines, search
/// results): a [media] area on top, the [title] with an optional [subtitle]
/// under it, and a details button at the bottom left.
class MedicineGridCard extends StatelessWidget {
  /// Shown centered in the 184:106 area at the top of the card.
  final Widget media;
  final String title;
  final String? subtitle;

  /// Overrides the subtitle's default color.
  final Color? subtitleColor;
  final String detailsLabel;
  final VoidCallback onDetailsTap;

  const MedicineGridCard({
    super.key,
    required this.media,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    required this.detailsLabel,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 184 / 106,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Center(child: media),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h, right: 9.w, left: 9.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.categoryMedicineName,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.categoryMedicineSubtitle.copyWith(color: subtitleColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 8.w,
              bottom: 12.h,
              child: SizedBox(
                width: 95.w,
                height: 24.h,
                child: OutlinedButton(
                  onPressed: onDetailsTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mainTeal,
                    backgroundColor: AppColors.permissionIconBg,
                    side: BorderSide(color: AppColors.iconBlueBorder.withAlpha(0xB8)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    detailsLabel,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The stand-in shown in a [MedicineGridCard]'s media area when a medicine
/// has no image.
class MedicinePlaceholderIcon extends StatelessWidget {
  const MedicinePlaceholderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.medication_outlined, size: 36.sp, color: AppColors.mainTeal);
  }
}
