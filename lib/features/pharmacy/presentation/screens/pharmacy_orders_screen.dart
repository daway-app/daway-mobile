import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/pharmacy_order.dart';
import '../widgets/pharmacy_order_card.dart';
import '../widgets/pharmacy_products_header.dart';
import 'pharmacy_order_details_screen.dart';

/// The pharmacy's الطلبات tab: every order as a card, newest first as handed
/// in, and "عرض الطلب" opens its details. A tab's root, so no back chip.
///
/// There is no orders API yet, so the shell hands in no orders and the screen
/// says there are none; the populated list is built and tested ahead of it.
class PharmacyOrdersScreen extends StatelessWidget {
  final List<PharmacyOrder> orders;

  const PharmacyOrdersScreen({super.key, this.orders = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
          children: [
            const PharmacyProductsHeader(
              title: 'الطلبات',
              subtitle: 'أدر المنتجات الخاصة بك',
            ),
            SizedBox(height: 24.h),
            if (orders.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: Text(
                  'لا توجد طلبات بعد.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.settingsMutedText,
                ),
              )
            else
              for (var i = 0; i < orders.length; i++) ...[
                if (i > 0) SizedBox(height: 16.h),
                PharmacyOrderCard(
                  order: orders[i],
                  onViewTap: () => PharmacyOrderDetailsScreen.open(context, orders[i]),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
