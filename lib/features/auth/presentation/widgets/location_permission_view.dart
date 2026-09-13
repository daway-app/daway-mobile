import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import 'permission_icon_header.dart';

/// Shared "allow location access" layout used by both the patient and
/// pharmacy sign-up flows — each screen wires this to its own cubit and
/// supplies the copy/color/state that differs between them.
class LocationPermissionView extends StatelessWidget {
  final String subtitle;
  final Color buttonColor;
  final String? errorText;
  final bool isBusy;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const LocationPermissionView({
    super.key,
    required this.subtitle,
    required this.buttonColor,
    required this.errorText,
    required this.isBusy,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 32.h),
          PermissionIconHeader(
            icon: Icons.location_on_outlined,
            title: 'اعثر على الأقرب إليك',
            subtitle: subtitle,
          ),
          SizedBox(height: 24.h),
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                errorText!,
                textAlign: TextAlign.center,
                style: AppTextStyles.authFieldError,
              ),
            ),
          AppCustomButton(
            text: 'السماح بالوصول للموقع',
            backgroundColor: buttonColor,
            isLoading: isBusy,
            onPressed: isBusy ? () {} : onAllow,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'تخطي',
              textAlign: TextAlign.center,
              style: AppTextStyles.authFooterMuted,
            ),
          ),
        ],
      ),
    );
  }
}
