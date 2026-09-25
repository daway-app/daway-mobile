import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';
import 'app_bottom_sheet.dart';

/// Bottom-sheet confirmation shown before ending the user's session. Purely
/// presentational: the caller decides what happens when the user confirms.
class LogoutConfirmationSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationSheet({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return AppBottomSheet.show<void>(
      context,
      builder: (_) => LogoutConfirmationSheet(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _LogoutIconCircle()),
          SizedBox(height: 24.h),
          Text(
            'تسجيل الخروج؟',
            textAlign: TextAlign.center,
            style: AppTextStyles.confirmSheetTitle,
          ),
          SizedBox(height: 16.h),
          Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
            textAlign: TextAlign.center,
            style: AppTextStyles.confirmSheetMessage,
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoutRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text('تسجيل الخروج', style: AppTextStyles.sheetButtonLabel),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 58.h,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sheetTitleText,
                side: const BorderSide(color: AppColors.sheetOutlineBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text('إلغاء', style: AppTextStyles.sheetButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutIconCircle extends StatelessWidget {
  const _LogoutIconCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68.r,
      height: 68.r,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.logoutRedTint, shape: BoxShape.circle),
      child: SvgPicture.asset(
        'assets/icons/log_out_icon.svg',
        width: 22.r,
        height: 22.r,
        colorFilter: const ColorFilter.mode(AppColors.logoutRed, BlendMode.srcIn),
      ),
    );
  }
}
