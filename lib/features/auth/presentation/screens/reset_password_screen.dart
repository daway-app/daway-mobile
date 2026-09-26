import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import '../widgets/auth_flow_header.dart';
import '../widgets/password_reset_notice_listener.dart';
import 'password_updated_screen.dart';

/// The third screen of resetting a password: choosing the new one.
///
/// Expects the [PasswordResetCubit] of [ForgotPasswordScreen] above it. Going
/// back from here takes the flow back to the code step; finishing replaces the
/// whole flow with [PasswordUpdatedScreen], over what the flow was opened from.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
                  previous.step == PasswordResetStep.newPassword &&
                  current.step == PasswordResetStep.done,
              listener: (context, state) {
                // The screens of the flow are behind the pharmacy now: only what
                // the flow was opened from (the login) stays under the confirmation.
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
                  _keepWhatIsBelowTheFlow(),
                );
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 32.h),
                    const AuthFlowHeader(
                      title: 'إعادة تعيين كلمة المرور',
                      subtitle: 'أنشئ كلمة مرور جديدة لحماية حسابك.',
                    ),
                    SizedBox(height: 22.h),
                    const _PasswordForm(),
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

/// For [NavigatorState.pushAndRemoveUntil]: removes the screens of the flow,
/// from the top of the stack down to and including the forgot-password screen
/// it began with, and keeps the route under that.
///
/// The route it keeps is not looked for by name, since the router names none of
/// its routes but the ones it must (the login is not named); the forgot-password
/// screen is. The routes are asked from the top down, so it remembers whether it
/// has passed that first screen.
RoutePredicate _keepWhatIsBelowTheFlow() {
  var passedTheFirstScreen = false;
  return (route) {
    if (route.isFirst || passedTheFirstScreen) return true;
    passedTheFirstScreen = route.settings.name == Routes.pharmacyForgotPasswordScreen;
    return false;
  };
}

class _PasswordForm extends StatefulWidget {
  const _PasswordForm();

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmationController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<PasswordResetCubit>().resetPassword(
          password: _passwordController.text,
          passwordConfirmation: _confirmationController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<PasswordResetCubit, PasswordResetState, String?>(
          selector: (state) => state.errorMessage,
          builder: (context, errorMessage) {
            final hasError = errorMessage != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthPasswordField(
                  label: 'كلمة المرور',
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  hasError: hasError,
                ),
                SizedBox(height: 22.h),
                AuthPasswordField(
                  label: 'تأكيد كلمة المرور',
                  controller: _confirmationController,
                  textInputAction: TextInputAction.done,
                  hasError: hasError,
                ),
                if (errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.authFieldError,
                  ),
                ],
              ],
            );
          },
        ),
        SizedBox(height: 24.h),
        BlocSelector<PasswordResetCubit, PasswordResetState, bool>(
          selector: (state) => state.isBusy,
          builder: (context, isBusy) {
            return AppCustomButton(
              text: 'تعيين كلمة المرور',
              textStyle: AppTextStyles.authFlowButton,
              backgroundColor: AppColors.mainTeal,
              isLoading: isBusy,
              onPressed: _submit,
            );
          },
        ),
      ],
    );
  }
}
