import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

/// Helper link under a verification-code field to ask for the code again, gated
/// by a 30-second countdown that starts with the screen and restarts on every
/// send.
///
/// It does not know who sends the code: [onResend] does that and says whether
/// it went out, and [isSending] shows a spinner meanwhile.
class ResendCodeLink extends StatefulWidget {
  /// Asks for a new code. True when it was sent, which restarts the countdown.
  final Future<bool> Function() onResend;
  final bool isSending;

  /// The text's size and weight; its colour is the link's.
  final TextStyle? textStyle;

  const ResendCodeLink({
    super.key,
    required this.onResend,
    this.isSending = false,
    this.textStyle,
  });

  @override
  State<ResendCodeLink> createState() => _ResendCodeLinkState();
}

class _ResendCodeLinkState extends State<ResendCodeLink> {
  static const _cooldownSeconds = 30;

  Timer? _timer;
  int _secondsLeft = _cooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedCountdown {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _resend() async {
    final sent = await widget.onResend();
    if (!mounted) return;
    if (sent) _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle ?? AppTextStyles.footerText;

    if (widget.isSending) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
      );
    }

    if (_secondsLeft > 0) {
      return Text(
        'إعادة الإرسال خلال $_formattedCountdown',
        style: style.copyWith(color: AppColors.authInputBorder),
      );
    }

    return GestureDetector(
      onTap: _resend,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh, size: 16.sp, color: AppColors.primaryTeal),
          SizedBox(width: 4.w),
          Text(
            'إعادة إرسال الرمز',
            style: style.copyWith(color: AppColors.primaryTeal, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
