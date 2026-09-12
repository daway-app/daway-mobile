import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/account_type.dart';
import '../cubit/account_type_cubit.dart';
import '../widgets/account_option_card.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),
                      const Center(child: AppLogo()),
                      SizedBox(height: 32.h),
                      Text(
                        'كيف ستستخدم دواك؟',
                        style: AppTextStyles.screenTitle.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'اختر نوع الحساب المناسب لاحتياجاتك.',
                        style: AppTextStyles.accountTypeSubtitle.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400, // Regular
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      BlocSelector<AccountTypeCubit, AccountType, bool>(
                        selector: (state) => state == AccountType.patient,
                        builder: (context, isSelected) => AccountOptionCard(
                          type: AccountType.patient,
                          isSelected: isSelected,
                          title: 'مستخدم',
                          description: 'اطلب أدويتك وتابع وصفاتك وطلباتك بسهولة.',
                          iconWidget: SvgPicture.asset(
                            "assets/icons/user_icon.svg",
                            width: 24.w,
                            height: 24.h,
                          ),
                          onTap: () => context
                              .read<AccountTypeCubit>()
                              .selectAccountType(AccountType.patient),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      BlocSelector<AccountTypeCubit, AccountType, bool>(
                        selector: (state) => state == AccountType.pharmacy,
                        builder: (context, isSelected) => AccountOptionCard(
                          type: AccountType.pharmacy,
                          isSelected: isSelected,
                          title: 'صيدلي',
                          description: 'أدر الأدوية والطلبات واستقبل طلبات المستخدمين.',
                          iconWidget: Image.asset(
                           "assets/icons/pharmacy-icon.png",
                            width: 24.w,
                            height: 24.h,
                          ),
                          onTap: () => context
                              .read<AccountTypeCubit>()
                              .selectAccountType(AccountType.pharmacy),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 56.h,
                width: double.infinity,
                child: AppCustomButton(
                  backgroundColor: AppColors.primaryTeal,
                  text: 'التالي',
                  onPressed: () {
                    final selectedType = context.read<AccountTypeCubit>().state;
                    if (selectedType == AccountType.patient) {
                      Navigator.pushNamed(context, Routes.patientAuthScreen);
                    } else {
                      Navigator.pushNamed(context, Routes.pharmacyAuthScreen);
                    }
                  },
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}