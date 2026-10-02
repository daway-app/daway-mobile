import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/pharmacy_order.dart';
import 'pharmacy_order_card.dart';

/// The "الطلبات" block of the pharmacy home: a header with a "عرض الكل" chip,
/// then one card per order.
class PharmacyOrdersSection extends StatelessWidget {
  final List<PharmacyOrder> orders;
  final VoidCallback onViewAllTap;
  final ValueChanged<PharmacyOrder> onOrderTap;

  const PharmacyOrdersSection({
    super.key,
    required this.orders,
    required this.onViewAllTap,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'الطلبات',
          onActionTap: onViewAllTap,
          titleStyle: AppTextStyles.pharmacySectionTitle,
          actionStyle: AppTextStyles.pharmacySectionAction,
          chevronColor: AppColors.mainTeal,
          chevronSize: 24,
        ),
        SizedBox(height: 8.h),
        for (var i = 0; i < orders.length; i++) ...[
          if (i > 0) SizedBox(height: 16.h),
          PharmacyOrderCard(order: orders[i], onViewTap: () => onOrderTap(orders[i])),
        ],
      ],
    );
  }
}
