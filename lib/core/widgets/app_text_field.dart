import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? icon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final bool obscureText;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  /// For a multi-line field (e.g. a notes area) — a single-line field's
  /// default of 1 is unaffected when left null.
  final int? maxLines;

  /// Overrides the default light-grey fill (e.g. white, for a field that
  /// should instead read by its border like the reminder screen's fields).
  final Color? fillColor;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.textAlign = TextAlign.right,
    this.obscureText = false,
    this.readOnly = false,
    this.onSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      obscureText: obscureText,
      readOnly: readOnly,
      // Explicit fallback to 1, not just omitting the argument when
      // [maxLines] is null — TextField's own default is 1 too, but relying
      // on that here would mean passing `maxLines: null` explicitly (since
      // this argument is always supplied), which Flutter treats as
      // "unlimited lines", not "use the default".
      maxLines: obscureText ? 1 : (maxLines ?? 1),
      style: TextStyle(fontSize: 16.sp, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.grey),
        suffixIcon: icon,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor ?? AppColors.inputFill,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
        ),
      ),
    );
  }
}
