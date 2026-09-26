import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The two big cards under the pharmacy home's header: the number of
/// products (which opens the products tab) and the month's sales.
class PharmacySummaryCards extends StatelessWidget {
  final int totalProducts;

  /// In shekels, or null while there is no figure to show — the mobile API
  /// has no sales endpoint yet, so the home passes null and the card shows a
  /// dash rather than a made-up 0.
  final double? monthlySales;
  final VoidCallback onProductsTap;

  const PharmacySummaryCards({
    super.key,
    required this.totalProducts,
    required this.monthlySales,
    required this.onProductsTap,
  });

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so both cards grow to the taller one if a large font
    // size makes either's text taller than their 133 minimum.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'إجمالي\nالمنتجات',
              onTap: onProductsTap,
              value: Text('$totalProducts', style: AppTextStyles.pharmacySummaryValue),
              trailing: const _ArrowIcon(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _SummaryCard(
              title: 'إجمالي المبيعات\nالشهرية',
              value: _SalesValue(amount: monthlySales),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SummaryCard({required this.title, required this.value, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      constraints: BoxConstraints(minHeight: 133.h),
      // As measured on the design, border included: the title is 18px down
      // from the card's top edge, the figure 17px up from its bottom edge,
      // and both are 16px in from the sides.
      padding: EdgeInsets.fromLTRB(15.w, 17.h, 15.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.permissionIconBg,
        border: Border.all(color: AppColors.iconBlueBorder),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.pharmacySummaryTitle),
          Row(
            children: [
              // Takes what the trailing icon leaves, and shrinks a long
              // figure to it instead of overflowing the card.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: value,
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
  }
}

/// The "←" at the far end of the products card, 8px in from the card's edge.
class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8.w),
      child: SvgPicture.asset('assets/icons/arrow_left_icon.svg', width: 24.w, height: 24.w),
    );
  }
}

class _SalesValue extends StatelessWidget {
  final double? amount;

  const _SalesValue({required this.amount});

  @override
  Widget build(BuildContext context) {
    final sales = amount;
    if (sales == null) return Text('-', style: AppTextStyles.pharmacySummaryValue);
    return Text.rich(
      TextSpan(
        style: AppTextStyles.pharmacySummaryValue,
        children: [
          TextSpan(text: 'ILS', style: AppTextStyles.pharmacySummaryCurrency),
          TextSpan(text: formatPrice(sales)),
        ],
      ),
    );
  }
}
