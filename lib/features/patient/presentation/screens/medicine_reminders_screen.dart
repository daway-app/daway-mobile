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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RemindersCubit>(),
        child: const _AddReminderSheet(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RemindersCubit>(),
        child: _AddReminderSheet(existing: reminder),
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

class _AddReminderSheet extends StatefulWidget {
  final MedicineReminder? existing;

  const _AddReminderSheet({this.existing});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  late final TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late List<bool> _selectedDays;

  static const _dayLabels = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _selectedTime = TimeOfDay(hour: e?.hour ?? 8, minute: e?.minute ?? 0);
    _selectedDays = List.generate(
      7,
      (i) => e?.daysOfWeek.contains(i) ?? true,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing != null ? 'تعديل التذكير' : 'إضافة تذكير جديد',
            textAlign: TextAlign.right,
            style: AppTextStyles.addressCardTitle,
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'اسم الدواء',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'الساعة ${_selectedTime.hour > 12 ? _selectedTime.hour - 12 : (_selectedTime.hour == 0 ? 12 : _selectedTime.hour)}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour < 12 ? 'ص' : 'م'}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.profileFieldValue,
                    ),
                  ),
                  Icon(Icons.access_time_rounded, size: 20.sp, color: AppColors.mainTeal),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.end,
            children: List.generate(7, (i) {
              return GestureDetector(
                onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _selectedDays[i]
                        ? AppColors.mainTeal
                        : AppColors.permissionIconBg,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _dayLabels[i],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _selectedDays[i] ? Colors.white : AppColors.onboardingText,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              if (widget.existing != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<RemindersCubit>().deleteReminder(widget.existing!.id);
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'حذف',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final days = <int>[];
    for (var i = 0; i < 7; i++) {
      if (_selectedDays[i]) days.add(i);
    }
    if (days.isEmpty) return;

    final reminder = MedicineReminder(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      daysOfWeek: days,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
    );
    context.read<RemindersCubit>().saveReminder(reminder);
    Navigator.of(context).pop();
  }
}
