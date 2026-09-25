import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

class FilterTabItem<T> {
  final T value;
  final String label;

  const FilterTabItem({required this.value, required this.label});
}

/// A horizontally scrolling row of single-select tabs ("الكل (7)", "مكتملة
/// (3)", ...) — the selected one solid teal, the rest outlined on a pale
/// blue wash.
///
/// Meant to be placed full-bleed (outside the screen's own horizontal
/// padding): it applies its own 24-wide side padding, so that tabs past the
/// edge of the screen scroll in from the very edge of the screen rather than
/// being clipped 24 short of it, as in the design.
class FilterTabsRow<T> extends StatelessWidget {
  final List<FilterTabItem<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelected;

  const FilterTabsRow({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) SizedBox(width: 16.w),
            _FilterTab(
              label: tabs[i].label,
              isSelected: tabs[i].value == selected,
              onTap: () => onSelected(tabs[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 32 tall selected (no border) / 34 tall unselected (1px border), as
        // in the design.
        height: isSelected ? 32.h : 34.h,
        // Safe here (unlike on a Container inside a bounded-width parent):
        // the scroll view gives this row unbounded width, so `alignment`
        // only centers the label vertically instead of stretching the tab.
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainTeal : AppColors.accountIconBg,
          borderRadius: BorderRadius.circular(5.r),
          border: isSelected ? null : Border.all(color: AppColors.iconBlueBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.mainTeal,
          ),
        ),
      ),
    );
  }
}
