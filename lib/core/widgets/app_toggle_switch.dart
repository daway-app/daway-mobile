import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

/// A purely visual on/off switch: a 50x28 track with a 22 thumb. It has no
/// tap handling of its own — put it in a tappable row and let the row decide
/// what a tap means (on the settings screen a tap opens system settings
/// rather than flipping the value).
///
/// The thumb is positioned with physical (not directional) alignment, so it
/// is on the right when on, as in the design, even inside the RTL app, where
/// Flutter's own [Switch] would mirror.
class AppToggleSwitch extends StatelessWidget {
  final bool value;

  const AppToggleSwitch({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50.w,
        height: 28.h,
        padding: EdgeInsets.all(3.r),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.mainTeal : AppColors.cardBorder,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Container(
          width: 22.r,
          height: 22.r,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
