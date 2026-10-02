import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// The last screen of resetting a password: a card in the middle of the screen
/// saying it worked. It has nothing to press — after [displayTime] it goes, and
/// the pharmacy is back at what the flow was opened from (the login): the
/// screens of the flow were removed when this one opened, so it is right under
/// it.
class PasswordUpdatedScreen extends StatefulWidget {
  /// How long the confirmation stays before the login is shown again.
  static const Duration displayTime = Duration(seconds: 2);

  const PasswordUpdatedScreen({super.key});

  @override
  State<PasswordUpdatedScreen> createState() => _PasswordUpdatedScreenState();
}

class _PasswordUpdatedScreenState extends State<PasswordUpdatedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(PasswordUpdatedScreen.displayTime, _backToLogin);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _backToLogin() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // No SafeArea: the card is centered on the whole screen, as in the design.
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: Container(
            // 392 by 342 inside a 1px border. The design gives it 48 above the
            // content and 67 below; measured, the content sits as if that were
            // 68, so 68 it is.
            height: 344.h,
            padding: EdgeInsets.fromLTRB(92.w, 48.h, 92.w, 68.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.iconBlueBorder),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/password_updated.jpg',
                    width: 142.4.w,
                    height: 142.4.w,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  SizedBox(height: 24.h),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'تم تحديث كلمة مرورك بنجاح',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.passwordUpdatedMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
