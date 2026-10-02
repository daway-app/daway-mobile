import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../domain/entities/patient_address.dart';

/// The names an address can be given. "آخر" is the catch-all, stored as-is.
const addressLabels = ['المنزل', 'العمل', 'آخر'];

enum AddressEditAction { save, changeLocation, delete }

class AddressEditResult {
  final AddressEditAction action;
  final String label;

  const AddressEditResult(this.action, this.label);
}

/// Bottom sheet asking what to call a new address (منزل / عمل / آخر).
/// Returns the picked label, or null if dismissed.
Future<String?> showAddressLabelSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => const _AddressLabelSheet(),
  );
}

/// Bottom sheet for a saved address: rename it, move it, or delete it.
Future<AddressEditResult?> showAddressEditSheet(
  BuildContext context,
  PatientAddress address,
) {
  return showModalBottomSheet<AddressEditResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => _AddressEditSheet(address: address),
  );
}

class _AddressLabelSheet extends StatefulWidget {
  const _AddressLabelSheet();

  @override
  State<_AddressLabelSheet> createState() => _AddressLabelSheetState();
}

class _AddressLabelSheetState extends State<_AddressLabelSheet> {
  // Local UI state: which chip is highlighted.
  String _selected = addressLabels.first;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ما نوع هذا العنوان؟',
                textAlign: TextAlign.right, style: AppTextStyles.allCategoriesTitle),
            SizedBox(height: 8.h),
            Text(
              'اختر اسماً يسهّل عليك التعرف عليه.',
              textAlign: TextAlign.right,
              style: AppTextStyles.allCategoriesSubtitle,
            ),
            SizedBox(height: 24.h),
            _LabelChips(
              selected: _selected,
              onSelected: (label) => setState(() => _selected = label),
            ),
            SizedBox(height: 32.h),
            AppCustomButton(
              text: 'حفظ العنوان',
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressEditSheet extends StatefulWidget {
  final PatientAddress address;

  const _AddressEditSheet({required this.address});

  @override
  State<_AddressEditSheet> createState() => _AddressEditSheetState();
}

class _AddressEditSheetState extends State<_AddressEditSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.address.label;
  }

  void _close(AddressEditAction action) =>
      Navigator.of(context).pop(AddressEditResult(action, _selected));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تعديل العنوان',
                textAlign: TextAlign.right, style: AppTextStyles.allCategoriesTitle),
            SizedBox(height: 8.h),
            Text(
              widget.address.address,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.allCategoriesSubtitle,
            ),
            SizedBox(height: 24.h),
            _LabelChips(
              selected: _selected,
              onSelected: (label) => setState(() => _selected = label),
            ),
            SizedBox(height: 32.h),
            AppCustomButton(text: 'حفظ', onPressed: () => _close(AddressEditAction.save)),
            SizedBox(height: 12.h),
            AppCustomButton(
              text: 'تغيير الموقع',
              backgroundColor: Colors.white,
              textColor: AppColors.onboardingText,
              borderColor: AppColors.iconBlueBorder,
              fontWeight: FontWeight.w500,
              onPressed: () => _close(AddressEditAction.changeLocation),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () => _close(AddressEditAction.delete),
              child: Text('حذف العنوان', style: TextStyle(color: AppColors.logoutRed)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _LabelChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final label in addressLabels)
          GestureDetector(
            onTap: () => onSelected(label),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: selected == label ? AppColors.mainTeal : AppColors.permissionIconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: selected == label ? Colors.white : AppColors.onboardingText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
