import 'package:daway_app/core/theming/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? trailingIcon;
  final FontWeight? fontWeight;

  /// Draws an outline in this colour — a secondary button (white/transparent
  /// [backgroundColor], bordered) instead of the default filled one.
  final Color? borderColor;
  /// The label's own style, in place of the theme's (its colour is still
  /// [textColor]'s, or white) — for a screen whose label is a real Tajawal
  /// weight, which a [fontWeight] over the theme's regular-only font cannot
  /// draw.
  final TextStyle? textStyle;

  const AppCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.trailingIcon,
    this.fontWeight,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.mainTeal,
          foregroundColor: textColor ?? Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          height: 24.h,
          width: 24.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: textStyle?.copyWith(color: textColor ?? Colors.white) ??
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: fontWeight ?? FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingIcon != null) ...[
              SizedBox(width: 8.w),
              Icon(trailingIcon, color: textColor ?? Colors.white, size: 20.sp),
            ],
          ],
        ),
      ),
    );
  }
}