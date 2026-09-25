import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The centered "دواك" mark and wordmark with the app version under it, at
/// the foot of the account-settings screen. The version line is left out
/// when [version] is null (it could not be read).
class SettingsBrandFooter extends StatelessWidget {
  final String? version;

  const SettingsBrandFooter({super.key, this.version});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // RTL order (first child is rightmost): the wordmark, then the mark
        // to its left, as in the design.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('دواك', style: AppTextStyles.settingsBrandName),
            SizedBox(width: 8.w),
            Container(
              width: 34.r,
              height: 34.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mainTeal,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.asset(
                'assets/icons/layers_icon.svg',
                width: 22.r,
                height: 22.r,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ],
        ),
        if (version != null) ...[
          SizedBox(height: 10.h),
          Text(
            'الإصدار $version',
            textAlign: TextAlign.center,
            style: AppTextStyles.settingsMutedText,
          ),
        ],
      ],
    );
  }
}
