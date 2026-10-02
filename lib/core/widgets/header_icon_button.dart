import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../theming/app_colors.dart';

/// The 42x42 outlined square that holds a header icon at the top of a screen:
/// an action (notifications, cart), a back chevron, or a save/bookmark
/// toggle — anywhere a screen needs more than [AppBackButton]'s fixed
/// right-aligned back chip (a custom background/icon colour, or a second one
/// placed on the opposite edge).
class HeaderIconButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;
  final double iconSize;

  /// The fill of the square — white, as behind the homes' action icons.
  final Color backgroundColor;

  /// Draws the icon in this one colour instead of the colours of its own.
  final Color? iconColor;

  /// What a screen reader says for the button; without one the button has no
  /// name of its own.
  final String? semanticLabel;

  const HeaderIconButton({
    super.key,
    required this.assetName,
    required this.onTap,
    this.iconSize = 22,
    this.backgroundColor = Colors.white,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.iconBlueBorder),
        ),
        child: SvgPicture.asset(
          assetName,
          width: iconSize.w,
          height: iconSize.w,
          colorFilter: iconColor == null ? null : ColorFilter.mode(iconColor!, BlendMode.srcIn),
        ),
      ),
    );

    final label = semanticLabel;
    if (label == null) return button;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: button,
    );
  }
}
