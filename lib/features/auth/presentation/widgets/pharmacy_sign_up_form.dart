import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/digits_only_formatter.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../cubit/pharmacy_sign_up_cubit.dart';
import '../cubit/pharmacy_sign_up_state.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_screen.dart';

/// Pharmacy name / phone / address / password fields shown on
/// [PharmacySignUpScreen].
class PharmacySignUpForm extends StatefulWidget {
  const PharmacySignUpForm({super.key});

  @override
  State<PharmacySignUpForm> createState() => _PharmacySignUpFormState();
}

class _PharmacySignUpFormState extends State<PharmacySignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<PharmacySignUpCubit>();
    cubit.detailsChanged(
      pharmacyName: _nameController.text.trim(),
      phone: _phoneController.text,
      address: _addressController.text.trim(),
      password: _passwordController.text,
    );
    cubit.register();
  }

  /// See [SignUpForm._consentLink] for why this is a [WidgetSpan].
  WidgetSpan _consentLink(String text, VoidCallback onTap) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.authTextPrimary, width: 1),
            ),
          ),
          child: Text(text, style: AppTextStyles.authConsentLink),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('اسم الصيدلية', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'اسم الصيدلية مطلوب' : null,
            decoration: _fieldDecoration(),
          ),

          SizedBox(height: 16.h),

          Text('رقم الجوال', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            inputFormatters: [DigitsOnlyFormatter()],
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'رقم الجوال مطلوب';
              if (!Validators.isValidLocalPhone(value)) {
                return 'يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام';
              }
              return null;
            },
            decoration: _fieldDecoration(),
          ),

          SizedBox(height: 16.h),

          Text('العنوان', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _addressController,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'العنوان مطلوب' : null,
            decoration: _fieldDecoration(),
          ),

          SizedBox(height: 16.h),

          Text('كلمة المرور', style: AppTextStyles.authFieldLabel, textAlign: TextAlign.right),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16.sp, color: AppColors.authTextPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
              if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              return null;
            },
            decoration: _fieldDecoration().copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          BlocBuilder<PharmacySignUpCubit, PharmacySignUpState>(
            buildWhen: (previous, current) => previous.registerError != current.registerError,
            builder: (context, state) {
              if (state.registerError == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  state.registerError!,
                  style: AppTextStyles.authFieldError,
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          BlocBuilder<PharmacySignUpCubit, PharmacySignUpState>(
            buildWhen: (previous, current) => previous.isRegistering != current.isRegistering,
            builder: (context, state) {
              return AppCustomButton(
                text: 'التالي',
                backgroundColor: AppColors.mainTeal,
                isLoading: state.isRegistering,
                onPressed: () => _submit(context),
              );
            },
          ),

          SizedBox(height: 16.h),

          Text.rich(
            TextSpan(
              style: AppTextStyles.authConsentText,
              children: [
                const TextSpan(text: 'بالضغط على '),
                TextSpan(text: 'التالي', style: AppTextStyles.authConsentLink),
                const TextSpan(text: ' أنت توافق على '),
                _consentLink(
                  'الشروط والأحكام',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                ),
                const TextSpan(text: ' و '),
                _consentLink(
                  'سياسة الخصوصية',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.authInputBorder, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.authError, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.authError, width: 1.5),
      ),
      errorStyle: AppTextStyles.authFieldError,
    );
  }
}
