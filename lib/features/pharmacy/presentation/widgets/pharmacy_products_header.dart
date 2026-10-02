import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/header_icon_button.dart';

/// The top of the products page: the back chip, the page title, and the line
/// under it.
class PharmacyProductsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const PharmacyProductsHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Text('اجمالي المنتجات', style: AppTextStyles.pharmacyPageTitle),
        SizedBox(height: 3.h),
        Text('أدر المنتجات الخاصة بك', style: AppTextStyles.pharmacyPageSubtitle),
      ],
    );
  }
}
