import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  /// Wraps the card in a tappable ripple (e.g. a notification card marking
  /// itself read) instead of the plain, non-interactive [Container] used
  /// when this is null.
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final decoration = BoxDecoration(
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
    final content = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(24.r),
      decoration: onTap == null
          ? decoration.copyWith(color: color ?? Colors.white)
          : decoration,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: color ?? Colors.white,
      borderRadius: radius,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}
