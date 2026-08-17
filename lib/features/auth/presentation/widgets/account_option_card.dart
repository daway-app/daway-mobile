import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/account_type.dart';

class AccountOptionCard extends StatelessWidget {
  final AccountType type;
  final bool isSelected;
  final String title;
  final String description;
  final Widget iconWidget;
  final Color iconBgColor;
  final VoidCallback onTap;

  const AccountOptionCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.iconWidget,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title. $description',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.04),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconWidget,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.cardDescription,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.chevron_left,
                  color: AppColors.cardChevron,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}