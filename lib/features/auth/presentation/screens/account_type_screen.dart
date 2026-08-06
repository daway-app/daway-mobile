import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../domain/entities/account_type.dart';
import '../cubit/account_type_cubit.dart';
import '../widgets/account_option_card.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 64.h),
                      Container(
                        width: 130.w,
                        height: 130.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      Text(
                        'اختر نوع الحساب',
                        style: AppTextStyles.screenTitle,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 32.h),

                      Column(
                        children: [
                          BlocSelector<AccountTypeCubit, AccountType, bool>(
                            selector: (state) => state == AccountType.patient,
                            builder: (context, isSelected) => AccountOptionCard(
                              type: AccountType.patient,
                              isSelected: isSelected,
                              title: 'حساب مريض',
                              description: 'احصل على أدوية بسهولة وتابع مواعيدك',
                              iconWidget: Icon(
                                Icons.person_outline,
                                color: AppColors.mainTeal,
                                size: 28.sp,
                              ),
                              iconBgColor: AppColors.patientIconBackground,
                              onTap: () => context
                                  .read<AccountTypeCubit>()
                                  .selectAccountType(AccountType.patient),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          BlocSelector<AccountTypeCubit, AccountType, bool>(
                            selector: (state) => state == AccountType.pharmacy,
                            builder: (context, isSelected) => AccountOptionCard(
                              type: AccountType.pharmacy,
                              isSelected: isSelected,
                              title: 'حساب صيدلية',
                              description: 'إدارة مخزونك وطلبات المرضى بكفاءة عالية',
                              iconWidget: SvgPicture.asset(
                                "assets/icons/pharmacy_icon.svg",
                                width: 28.w,
                                height: 28.h,
                              ),
                              iconBgColor: AppColors.pharmacyIconBackground,
                              onTap: () => context
                                  .read<AccountTypeCubit>()
                                  .selectAccountType(AccountType.pharmacy),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      AppCustomButton(
                        backgroundColor: AppColors.continueButtonBackground,
                        text: 'متابعة التسجيل',
                        onPressed: () {
                          final selectedType =
                              context.read<AccountTypeCubit>().state;
                          if (selectedType == AccountType.patient) {
                            // TODO: Navigator.pushNamed(context, Routes.patientRegisterOtp);
                          } else {
                            // TODO: Navigator.pushNamed(context, Routes.pharmacyRegister);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'تواصل معنا',
                        style: AppTextStyles.footerText,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'تحتاج إلى مساعدة؟',
                      style: AppTextStyles.footerText,
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.help_outline,
                      size: 18.sp,
                      color: AppColors.greyText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}