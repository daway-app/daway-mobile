import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';

/// Shared header for patient sub-screens reached from the account hub (e.g.
/// account info, addresses) — a back button, then a bold title and a muted
/// description below it.
class PatientSubScreenHeader extends StatelessWidget {
  final String title;
  final String description;

  const PatientSubScreenHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 32.h),
        AppBackButton(onTap: () => Navigator.of(context).pop()),
        SizedBox(height: 16.h),
        Text(title, textAlign: TextAlign.right, style: AppTextStyles.authScreenTitle),
        SizedBox(height: 8.h),
        Text(description, textAlign: TextAlign.right, style: AppTextStyles.authScreenSubtitle),
      ],
    );
  }
}
