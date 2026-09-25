import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// One tappable card on the account hub and the account-settings screen: an
/// optional [leading] icon, the [label], and an optional [trailing] widget (a
/// value, a chevron, a switch). Laid out right-to-left like the rest of the
/// app, so [leading] sits on the right edge and [trailing] on the left.
class AccountRowCard extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final double height;
  final double radius;

  const AccountRowCard({
    super.key,
    this.leading,
    required this.label,
    this.labelColor,
    this.trailing,
    required this.onTap,
    this.height = 56,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius.r);
    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          height: height.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, SizedBox(width: 8.w)],
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.accountMenuLabel.copyWith(color: labelColor),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A 22x22 row icon from an SVG asset, tinted (the app teal unless [color]
/// says otherwise).
class AccountRowIcon extends StatelessWidget {
  final String asset;
  final Color color;

  const AccountRowIcon(this.asset, {super.key, this.color = AppColors.mainTeal});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 22.r,
      height: 22.r,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// The light "<" at the left end of a row that opens something.
class AccountRowChevron extends StatelessWidget {
  const AccountRowChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.r,
      height: 18.r,
      child: Center(child: SvgPicture.asset('assets/icons/left_icon.svg', height: 10.h)),
    );
  }
}
