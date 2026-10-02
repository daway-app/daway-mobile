import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/entities/medicine_reminder.dart';
import '../cubit/reminders_cubit.dart';
import '../cubit/reminders_state.dart';
import 'add_medicine_reminder_screen.dart';

class MedicineRemindersScreen extends StatelessWidget {
  const MedicineRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RemindersCubit>(),
      child: const _MedicineRemindersView(),
    );
  }
}

class _MedicineRemindersView extends StatelessWidget {
  const _MedicineRemindersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.accountIconBg,
                      border: Border.all(color: AppColors.iconBlueBorder),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/back_icon.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.mainTeal,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'تذكيرات الأدوية',
                textAlign: TextAlign.right,
                style: AppTextStyles.allCategoriesTitle,
              ),
              SizedBox(height: 8.h),
              Text(
                'أضف الادوية لتذكيرك فيها بالوقت المناسب',
                textAlign: TextAlign.right,
                style: AppTextStyles.allCategoriesSubtitle,
              ),
              SizedBox(height: 22.h),
              Expanded(
                child: BlocBuilder<RemindersCubit, RemindersState>(
                  builder: (context, state) {
                    return switch (state) {
                      RemindersLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      RemindersFailure(:final message) => Center(
                          child: Text(message, textAlign: TextAlign.center),
                        ),
                      RemindersLoaded(:final reminders) =>
                        _RemindersList(reminders: reminders),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemindersList extends StatelessWidget {
  final List<MedicineReminder> reminders;

  const _RemindersList({required this.reminders});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return ListView(
        children: [
          EmptyStateView(
            imageAsset: 'assets/images/empty_reminder.png',
            title: 'لم تقم باضافة اي تذكير لادويتك',
            actionLabel: 'أضف تذكير',
            onActionTap: () => _showAddDialog(context),
            // This screen's own header is ~19 shorter than the shared
            // sub-screen header (and adds a 22 gap), so this lands the
            // illustration at the same height as on the other list screens.
            topSpacing: 78,
          ),
        ],
      );
    }

    return ListView(
      children: [
        ...reminders.map((r) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: _ReminderCard(reminder: r),
            )),
        _AddReminderButton(
          onTap: () => _showAddDialog(context),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RemindersCubit>(),
          child: const AddMedicineReminderScreen(),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.name,
                      style: AppTextStyles.addressCardTitle,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.permissionIconBg,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        reminder.scheduleLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mainTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.permissionIconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تعديل',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mainTeal,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/icons/edit_icon.svg',
                        width: 11.w,
                        height: 11.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Alert time bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.permissionIconBg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border(
                top: BorderSide(
                  color: AppColors.iconBlueBorder,
                  width: 1.05,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.alertLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time_rounded,
                  size: 18.sp,
                  color: AppColors.mainTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RemindersCubit>(),
          child: AddMedicineReminderScreen(existing: reminder),
        ),
      ),
    );
  }
}

class _AddReminderButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddReminderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'اضافة تذكير جديد',
                textAlign: TextAlign.right,
                style: AppTextStyles.addressCardTitle,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.permissionIconBg,
                border: Border.all(color: AppColors.iconBlueBorder),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.add,
                size: 16.sp,
                color: AppColors.mainTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

