import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';

/// A language the picker offers: its name in its own language, and a small
/// line under it in the other one.
enum AppLanguage {
  arabic('العربية', 'Arabic'),
  english('English', 'الإنجليزية');

  final String nativeName;
  final String subtitle;

  const AppLanguage(this.nativeName, this.subtitle);
}

/// "اختر اللغة": lists the [AppLanguage]s with [selected] highlighted;
/// tapping one closes the sheet with it as the result.
class LanguageBottomSheet extends StatelessWidget {
  final AppLanguage selected;

  const LanguageBottomSheet({super.key, required this.selected});

  static Future<AppLanguage?> show(BuildContext context, {required AppLanguage selected}) {
    return AppBottomSheet.show<AppLanguage>(
      context,
      builder: (_) => LanguageBottomSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 22 of side padding rather than 24: the highlighted option paints its
    // 2px border outside the 392 layout width, so it takes the full 396 and
    // the other cards are inset by the difference.
    return AppBottomSheet(
      padding: EdgeInsets.fromLTRB(22.w, 44.h, 22.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'اختر اللغة',
              textAlign: TextAlign.right,
              style: AppTextStyles.sheetHeading,
            ),
          ),
          SizedBox(height: 6.h),
          for (final language in AppLanguage.values) ...[
            _LanguageOption(
              language: language,
              isSelected: language == selected,
              onTap: () => Navigator.of(context).pop(language),
            ),
            if (language != AppLanguage.values.last) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final option = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: isSelected ? 76.h : 74.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.permissionIconBg : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.iconBlueBorder : AppColors.sheetOutlineBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        // RTL order (first child is rightmost): the names on the right, the
        // radio at the left end.
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.nativeName, style: AppTextStyles.sheetOptionTitle),
                  Text(language.subtitle, style: AppTextStyles.sheetOptionSubtitle),
                ],
              ),
            ),
            _Radio(isSelected: isSelected),
          ],
        ),
      ),
    );

    // The unselected cards are 4 narrower than the highlighted one.
    return isSelected
        ? option
        : Padding(padding: EdgeInsets.symmetric(horizontal: 2.w), child: option);
  }
}

class _Radio extends StatelessWidget {
  final bool isSelected;

  const _Radio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.r,
      height: 24.r,
      child: Center(
        child: isSelected
            ? Container(
                width: 24.r,
                height: 24.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.mainTeal, shape: BoxShape.circle),
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              )
            : Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                ),
              ),
      ),
    );
  }
}
