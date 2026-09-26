import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/digits_only_formatter.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import '../widgets/auth_flow_header.dart';
import '../widgets/password_reset_notice_listener.dart';
import 'password_reset_code_screen.dart';

/// The first screen of resetting a pharmacy's forgotten password, reached from
/// the login: the phone number the code is to be sent to.
///
/// Expects a [PasswordResetCubit] above it, which the screens after this one
/// share.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PasswordResetNoticeListener(
          child: BlocListener<PasswordResetCubit, PasswordResetState>(
            // Only the phone being accepted opens the code screen: going back to
            // the code step from the new password one must not open a second.
            listenWhen: (previous, current) =>
                previous.step == PasswordResetStep.phone && current.step == PasswordResetStep.code,
            listener: (context, state) {
              final cubit = context.read<PasswordResetCubit>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const PasswordResetCodeScreen(),
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
                  const AuthFlowHeader(
                    title: 'نسيت كلمة المرور ؟',
                    subtitle: 'أدخل رقم هاتفك لنرسل لك رمز التحقق لإعادة تعيين كلمة المرور.',
                    // Lower than on the other screens, as in the design.
                    titleTop: 21,
                    subtitleGap: 4,
                  ),
                  SizedBox(height: 14.h),
                  const _PhoneForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneForm extends StatefulWidget {
  const _PhoneForm();

  @override
  State<_PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends State<_PhoneForm> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() => context.read<PasswordResetCubit>().sendCode(_phoneController.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<PasswordResetCubit, PasswordResetState, String?>(
          selector: (state) => state.errorMessage,
          builder: (context, errorMessage) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [DigitsOnlyFormatter()],
                  textInputAction: TextInputAction.done,
                  hasError: errorMessage != null,
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
              text: 'التالي',
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
