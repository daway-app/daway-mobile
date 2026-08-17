import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_text_styles.dart';
import 'app_custom_button.dart';

/// Centered error message + retry button, shown when a profile screen
/// (patient, pharmacy, ...) fails to load its data.
class ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProfileLoadError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AppTextStyles.authSubtitle, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            AppCustomButton(text: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
