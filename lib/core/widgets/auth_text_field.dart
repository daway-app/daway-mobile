import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// A labelled outlined field of the auth flows: the label above (right-aligned
/// in the right-to-left page), then a 56px field with an 8px corner and a grey
/// border that turns blue when focused and red when [hasError].
///
/// It only draws — what is typed is in [controller], and a message about it is
/// shown by whoever owns the state, under the field.
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool hasError;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textDirection,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.textInputAction,
    this.hasError = false,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, textAlign: TextAlign.right, style: AppTextStyles.authFlowFieldLabel),
        SizedBox(height: 5.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          onChanged: onChanged,
          textInputAction: textInputAction,
          textAlign: TextAlign.start,
          style: AppTextStyles.authFlowInput,
          cursorColor: AppColors.primaryTeal,
          decoration: InputDecoration(
            // 16 above and below the 24px line: the field is 56 tall.
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            fillColor: Colors.white,
            filled: true,
            suffixIcon: suffixIcon,
            enabledBorder: _border(hasError ? AppColors.authError : AppColors.authInputBorder, 1),
            focusedBorder: _border(hasError ? AppColors.authError : AppColors.primaryTeal, 1.5),
          ),
        ),
      ],
    );
  }
}

/// An [AuthTextField] for a password, with the eye that shows or hides it.
class AuthPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool hasError;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.textInputAction,
    this.hasError = false,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      hasError: widget.hasError,
      suffixIcon: IconButton(
        tooltip: _obscure ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.grey,
          size: 20.sp,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
