import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Placeholder for a bottom-nav tab that doesn't have a real screen yet —
/// keeps the tab reachable and consistent (AppBar + side menu) instead of
/// just omitting it. [drawer] is passed in since each role has its own side
/// menu.
class ComingSoonTabScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget drawer;

  const ComingSoonTabScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(title, style: AppTextStyles.screenTitle),
      ),
      drawer: drawer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.sp, color: AppColors.grey),
            SizedBox(height: 12.h),
            Text('قريباً', style: AppTextStyles.authSubtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
