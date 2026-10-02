import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/header_icon_button.dart';

/// The top of a password-reset screen: the back chip, the title, and the line
/// or two under it. Meant to sit in a column that is [Column.crossAxisAlignment]
/// stretch, under the 32px the screens leave below the status bar.
class AuthFlowHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Space between the back chip and the title.
  final double titleTop;

  /// Space between the title and the subtitle.
  final double subtitleGap;

  const AuthFlowHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleTop = 13,
    this.subtitleGap = 12,
  });

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
            semanticLabel: 'رجوع',
            // maybePop, so the screen's own PopScope hears of it like of the
            // system back button.
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        SizedBox(height: titleTop.h),
        Text(title, style: AppTextStyles.authFlowTitle),
        SizedBox(height: subtitleGap.h),
        Text(subtitle, style: AppTextStyles.authFlowSubtitle),
      ],
    );
  }
}
