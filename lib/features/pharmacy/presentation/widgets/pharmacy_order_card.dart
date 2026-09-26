import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/arabic_plural.dart';
import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/pharmacy_order.dart';

/// One order on the pharmacy home: its number and how long ago it came in, a
/// strip with what is in it, and a "عرض الطلب" button.
class PharmacyOrderCard extends StatelessWidget {
  final PharmacyOrder order;
  final VoidCallback onViewTap;

  const PharmacyOrderCard({super.key, required this.order, required this.onViewTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36.h,
            child: Padding(
              // 12 on the number's side, 8 on the time's: how the design
              // places them.
              padding: EdgeInsetsDirectional.only(start: 12.w, end: 8.w),
              child: Row(
                children: [
                  // The number is Latin, so it is set left-to-right on its
                  // own: in the RTL paragraph its "#" would otherwise end up
                  // after the letters.
                  Text(
                    '#${order.orderNumber}',
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.pharmacyOrderNumber,
                  ),
                  SizedBox(width: 8.w),
                  // The number keeps its room; a long absolute date ("3 مايو
                  // 2025، 11:15 ص") is cut off rather than overflowing.
                  Expanded(
                    child: Text(
                      compactRelativeTimeAr(order.createdAt),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.pharmacyOrderTime,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
          SizedBox(height: 14.h),
          _SummaryStrip(order: order),
          SizedBox(height: 24.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ViewOrderButton(onTap: onViewTap),
          ),
        ],
      ),
    );
  }
}

/// The blue box under the header: item count, price and destination, in
/// three 100px cells centered in the card.
class _SummaryStrip extends StatelessWidget {
  final PharmacyOrder order;

  const _SummaryStrip({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.permissionIconBg,
        border: Border.all(color: AppColors.iconBlueBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      // RTL order (the first child is rightmost): items, price, destination.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SummaryCell(
            glyph: '💊',
            label: arabicCountedNoun(
              order.itemsCount,
              singular: 'دواء',
              dual: 'دواءان',
              plural: 'أدوية',
              one: 'دواء واحد',
            ),
          ),
          const _CellDivider(),
          _SummaryCell(
            glyph: '₪',
            glyphColor: AppColors.mainTeal,
            // Drawn from a different font than the emoji, so it sits lower.
            glyphLift: 2,
            label: '${formatPrice(order.total)} ₪',
            labelStyle: AppTextStyles.pharmacyOrderPrice,
            // Number first, then the ₪, as in the design: left in the RTL
            // paragraph the ₪ would land before the digits.
            labelDirection: TextDirection.ltr,
          ),
          const _CellDivider(),
          _SummaryCell(glyph: '📍', label: order.area),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  /// The icon above the label — a text glyph (💊 ₪ 📍), as in the design.
  final String glyph;
  final Color? glyphColor;

  /// How far, in px, to raise the glyph so it sits where the design's does.
  final double glyphLift;
  final String label;
  final TextStyle? labelStyle;
  final TextDirection? labelDirection;

  const _SummaryCell({
    required this.glyph,
    this.glyphColor,
    this.glyphLift = 0,
    required this.label,
    this.labelStyle,
    this.labelDirection,
  });

  @override
  Widget build(BuildContext context) {
    final style = labelStyle ?? AppTextStyles.pharmacyOrderSummary;
    return SizedBox(
      width: 100.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 14.h,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -glyphLift.h),
                child: Text(glyph, style: TextStyle(fontSize: 12.sp, color: glyphColor)),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textDirection: labelDirection,
            style: style,
            // Every line is exactly the style's height: the ₪ (which Tajawal
            // lacks) is drawn from another font, and its taller line would
            // stretch the whole strip by a few pixels.
            strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
          ),
        ],
      ),
    );
  }
}

class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34.h, color: AppColors.iconBlueBorder);
  }
}

class _ViewOrderButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewOrderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.permissionIconBg,
          border: Border.all(color: AppColors.iconBlueBorder),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('عرض الطلب', style: AppTextStyles.pharmacyOrderButton),
            SvgPicture.asset(
              'assets/icons/arrow_icon.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
