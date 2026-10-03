import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/header_icon_button.dart';

/// The top of a pharmacy page (products, orders, order details): the back
/// chip, the page title, and the line under it. A page that is a tab's root has nothing to go back to, so without
/// an [onBack] the chip is left out.
class PharmacyProductsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const PharmacyProductsHeader({
    super.key,
    this.title = 'اجمالي المنتجات',
    this.subtitle = 'أدر المنتجات الخاصة بك',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBack case final onBack?) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeaderIconButton(
              assetName: 'assets/icons/back_icon.svg',
              iconSize: 24,
              backgroundColor: AppColors.accountIconBg,
              iconColor: AppColors.mainTeal,
              semanticLabel: 'رجوع',
              onTap: onBack,
            ),
          ),
          SizedBox(height: 4.h),
        ],
        Text(title, style: AppTextStyles.pharmacyPageTitle),
        SizedBox(height: 3.h),
        Text(subtitle, style: AppTextStyles.pharmacyPageSubtitle),
      ],
    );
  }
}
