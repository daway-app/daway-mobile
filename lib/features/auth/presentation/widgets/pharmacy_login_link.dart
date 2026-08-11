import 'package:flutter/material.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Helper link under the phone-entry card pointing pharmacy users back to
/// account-type selection.
class PharmacyLoginLink extends StatelessWidget {
  const PharmacyLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed(Routes.accountTypeScreen),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.footerText,
          children: [
            const TextSpan(text: 'هل أنت صيدلية؟ '),
            TextSpan(
              text: 'سجّل دخولك من هنا',
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
