import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';

/// Static, read-only content screen shared by [TermsScreen] and
/// [PrivacyPolicyScreen] — same back button and layout, different title/body.
class LegalContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalContentScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48.h),
              AppBackButton(onTap: () => Navigator.of(context).pop()),
              SizedBox(height: 24.h),
              Text(title, textAlign: TextAlign.right, style: AppTextStyles.authScreenTitle),
              SizedBox(height: 16.h),
              Text(
                body,
                textAlign: TextAlign.right,
                style: AppTextStyles.authScreenSubtitle.copyWith(height: 1.6),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
