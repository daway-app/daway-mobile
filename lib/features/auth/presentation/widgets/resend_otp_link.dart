import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';

/// Helper link under the OTP card to resend the verification code, gated by
/// a 30-second countdown that resets on every send.
class ResendOtpLink extends StatefulWidget {
  const ResendOtpLink({super.key});

  @override
  State<ResendOtpLink> createState() => _ResendOtpLinkState();
}

class _ResendOtpLinkState extends State<ResendOtpLink> {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientAuthCubit, PatientAuthState>(
      buildWhen: (previous, current) => previous.isSendingOtp != current.isSendingOtp,
      builder: (context, state) {
        if (state.isSendingOtp) {
          return SizedBox(
            width: 14.w,
            height: 14.w,
            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
          );
        }

        if (_secondsLeft > 0) {
          return Text(
            'إعادة الإرسال خلال $_formattedCountdown',
            style: AppTextStyles.footerText.copyWith(color: AppColors.authInputBorder),
          );
        }

        return GestureDetector(
          onTap: () async {
            final cubit = context.read<PatientAuthCubit>();
            await cubit.sendOtp();
            if (!mounted) return;
            if (cubit.state.errorMessage == null) _startCooldown();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 16.sp, color: AppColors.primaryTeal),
              SizedBox(width: 4.w),
              Text(
                'إعادة إرسال الرمز',
                style: AppTextStyles.footerText.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
