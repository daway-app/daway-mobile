import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The row of four small stat tiles under the summary cards: available, low
/// stock, out of stock, and the pharmacy's average rating.
class PharmacyStatTiles extends StatelessWidget {
  final int available;
  final int lowStock;
  final int outOfStock;

  /// Null when the pharmacy has no ratings yet — the tile then shows a dash.
  final double? averageRating;
  final VoidCallback onRatingsTap;

  const PharmacyStatTiles({
    super.key,
    required this.available,
    required this.lowStock,
    required this.outOfStock,
    required this.averageRating,
    required this.onRatingsTap,
  });

  @override
  Widget build(BuildContext context) {
    // The design's four 91.5px tiles and three 8px gaps fill 390px of the
    // 392 the row has, and start 2px in from the right edge.
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 2.w),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(value: '$available', label: 'متوفرة', color: AppColors.statAvailable),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatTile(value: '$lowStock', label: 'مخزون منخفض', color: AppColors.statLowStock),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatTile(value: '$outOfStock', label: 'نافد', color: AppColors.statOutOfStock),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatTile(
              value: averageRating?.toStringAsFixed(1) ?? '-',
              label: 'التقييمات',
              color: AppColors.statRatings,
              onTap: onRatingsTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatTile({required this.value, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      constraints: BoxConstraints(minHeight: 76.h),
      // 2px more above than below: the design sets the figure and its caption
      // that much lower than a centered pair would sit.
      padding: EdgeInsets.fromLTRB(8.r, 10.r, 8.r, 8.r),
      decoration: BoxDecoration(
        // The design's tint is the tile's own colour at 0x0D / 255 (5%).
        color: color.withValues(alpha: 0x0D / 255),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTextStyles.pharmacyTileValue.copyWith(color: color)),
          SizedBox(height: 2.h),
          // Scales "مخزون منخفض" down on a narrow phone rather than letting
          // it wrap or be cut.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: AppTextStyles.pharmacyTileLabel.copyWith(color: color)),
          ),
        ],
      ),
    );

    if (onTap == null) return tile;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: tile);
  }
}
