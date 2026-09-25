import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/arabic_plural.dart';
import '../../../../core/helpers/price_formatter.dart';
import '../../../../core/helpers/smart_date_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/order.dart';
import 'order_status_badge.dart';

/// One order in "طلباتي" — pharmacy name/status, an item/price/location
/// summary strip, and a "عرض الطلب" action with the order's relative time.
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewTap;

  const OrderCard({super.key, required this.order, required this.onViewTap});

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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    // `start`, not `end`: this app is RTL, so `start` is the
                    // right edge where the pharmacy name belongs.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.pharmacyName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.orderCardPharmacyName,
                      ),
                      Text(
                        '#${order.orderNumber}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.orderCardMuted,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              border: Border.all(color: AppColors.iconBlueBorder, width: 1.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            // RTL order (first child is rightmost): items count, price,
            // then location — as in the design.
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.medication_outlined,
                    label: arabicCountedNoun(
                      order.itemsCount,
                      singular: 'دواء',
                      dual: 'دواءان',
                      plural: 'أدوية',
                      one: 'دواء واحد',
                    ),
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.sell_outlined,
                    label: '${formatPrice(order.price)} ₪',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.location_on_outlined,
                    label: order.address,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              SizedBox(
                height: 34.h,
                child: OutlinedButton(
                  onPressed: onViewTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mainTeal,
                    backgroundColor: AppColors.permissionIconBg,
                    side: BorderSide(color: AppColors.iconBlueBorder),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: Text(
                    'عرض الطلب',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Flexible, so a long absolute date ("3 مايو 2025، 11:15 ص")
              // next to the button ellipsizes instead of overflowing the card.
              Expanded(
                child: Text(
                  smartDate(order.createdAt),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.orderCardMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.mainTeal),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppColors.onboardingText),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColors.iconBlueBorder,
    );
  }
}
