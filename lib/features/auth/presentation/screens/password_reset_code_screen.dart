import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/phone_mask.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../../domain/usecases/verify_password_reset_code_usecase.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import '../widgets/auth_flow_header.dart';
import '../widgets/password_reset_notice_listener.dart';
import '../widgets/resend_code_link.dart';
import 'reset_password_screen.dart';

/// The second screen of resetting a password: the code sent to the phone.
///
/// Expects the [PasswordResetCubit] of [ForgotPasswordScreen] above it. Going
/// back from here takes the flow back to the phone step.
class PasswordResetCodeScreen extends StatelessWidget {
  const PasswordResetCodeScreen({super.key});

  // The number is one left-to-right unit in the right-to-left line: isolated,
  // so its "+" stays in front of it.
  static String _subtitle(String phone) =>
      'أدخل رمز التحقق المرسل إلى رقم هاتفك\nللمتابعة \u2066${maskLocalPhone(phone)}\u2069';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) context.read<PasswordResetCubit>().back();
      },
      child: Scaffold(
        body: SafeArea(
          child: PasswordResetNoticeListener(
            child: BlocListener<PasswordResetCubit, PasswordResetState>(
              listenWhen: (previous, current) =>
                  previous.step == PasswordResetStep.code &&
                  current.step == PasswordResetStep.newPassword,
              listener: (context, state) {
                final cubit = context.read<PasswordResetCubit>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const ResetPasswordScreen(),
                    ),
                  ),
                );
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 32.h),
                    BlocSelector<PasswordResetCubit, PasswordResetState, String>(
                      selector: (state) => state.phone,
                      builder: (context, phone) => AuthFlowHeader(
                        title: 'أدخل رمز التحقق',
                        subtitle: _subtitle(phone),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const _CodeForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeForm extends StatefulWidget {
  const _CodeForm();

  @override
  State<_CodeForm> createState() => _CodeFormState();
}

class _CodeFormState extends State<_CodeForm> {
  String _code = '';
  bool _isResending = false;

  Future<bool> _resend() async {
    setState(() => _isResending = true);
    final sent = await context.read<PasswordResetCubit>().resendCode();
    if (mounted) setState(() => _isResending = false);
    return sent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<PasswordResetCubit, PasswordResetState, String?>(
          selector: (state) => state.errorMessage,
          builder: (context, errorMessage) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtpInputField(
                  length: passwordResetCodeLength,
                  hasError: errorMessage != null,
                  onChanged: (value) => setState(() => _code = value),
                ),
                if (errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    errorMessage,
                    style: AppTextStyles.authFieldError.copyWith(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            );
          },
        ),
        // 25 under the boxes — whose widget is 4 taller than they are.
        SizedBox(height: 21.h),
        BlocSelector<PasswordResetCubit, PasswordResetState, bool>(
          selector: (state) => state.isBusy,
          builder: (context, isBusy) {
            return AppCustomButton(
              text: 'تحقق',
              textStyle: AppTextStyles.authFlowButton,
              backgroundColor: AppColors.mainTeal,
              isLoading: isBusy,
              onPressed: () => context.read<PasswordResetCubit>().verifyCode(_code),
            );
          },
        ),
        SizedBox(height: 48.h),
        Center(
          child: ResendCodeLink(
            isSending: _isResending,
            onResend: _resend,
            textStyle: AppTextStyles.authFlowResend,
          ),
        ),
      ],
    );
  }
}
