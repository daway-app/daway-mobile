import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

/// The shared chrome of the app's modal bottom sheets: a white panel with 16
/// rounded top corners and the caller's [padding].
///
/// The design's bottom padding (40+) already reaches under a phone's home
/// indicator (a 34 inset in the design frame), so it is only grown when the
/// device's bottom inset needs more room than that: the bottom padding is the
/// larger of [padding]'s and the inset plus 6.
class AppBottomSheet extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  const AppBottomSheet({super.key, required this.padding, required this.child});

  static Future<T?> show<T>(BuildContext context, {required WidgetBuilder builder}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.sheetBarrier,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: padding.copyWith(bottom: math.max(padding.bottom, bottomInset + 6.h)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: child,
    );
  }
}
