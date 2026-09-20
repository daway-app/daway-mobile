import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../domain/entities/category_subcategory.dart';
import '../cubit/category_medicines_cubit.dart';

/// Arabic section titles for the subcategory `group_key`s the backend sends
/// today (see the Categories API doc comment on [CategorySubcategory]).
/// Unknown group keys fall back to the key itself so a new one doesn't
/// silently disappear from the screen.
const Map<String, String> _groupTitles = {
  'symptoms': 'الأعراض',
  'vitamins': 'الفيتامينات',
  'supplements': 'المكملات',
};

class CategoryFilterResult {
  final String? subcategorySlug;
  final String? dosageForm;

  const CategoryFilterResult({this.subcategorySlug, this.dosageForm});
}

Future<CategoryFilterResult?> showCategoryFilterScreen(
  BuildContext context, {
  required CategoryMedicinesCubit cubit,
  required List<CategorySubcategory> subcategories,
  required List<String> dosageForms,
  required String? initialSubcategorySlug,
  required String? initialDosageForm,
  required int initialTotal,
}) {
  return Navigator.of(context).push<CategoryFilterResult>(
    MaterialPageRoute(
      builder: (_) => CategoryFilterScreen(
        cubit: cubit,
        subcategories: subcategories,
        dosageForms: dosageForms,
        initialSubcategorySlug: initialSubcategorySlug,
        initialDosageForm: initialDosageForm,
        initialTotal: initialTotal,
      ),
    ),
  );
}

class CategoryFilterScreen extends StatefulWidget {
  final CategoryMedicinesCubit cubit;
  final List<CategorySubcategory> subcategories;
  final List<String> dosageForms;
  final String? initialSubcategorySlug;
  final String? initialDosageForm;
  final int initialTotal;

  const CategoryFilterScreen({
    super.key,
    required this.cubit,
    required this.subcategories,
    required this.dosageForms,
    required this.initialSubcategorySlug,
    required this.initialDosageForm,
    required this.initialTotal,
  });

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  String? _subcategorySlug;
  String? _dosageForm;
  late int _resultCount;
  bool _isCounting = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subcategorySlug = widget.initialSubcategorySlug;
    _dosageForm = widget.initialDosageForm;
    _resultCount = widget.initialTotal;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() => _isCounting = true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final count = await widget.cubit.previewResultCount(
        subcategorySlug: _subcategorySlug,
        dosageForm: _dosageForm,
      );
      if (!mounted) return;
      setState(() {
        _isCounting = false;
        if (count != null) _resultCount = count;
      });
    });
  }

  Map<String, List<CategorySubcategory>> get _groupedSubcategories {
    final grouped = <String, List<CategorySubcategory>>{};
    for (final subcategory in widget.subcategories) {
      grouped.putIfAbsent(subcategory.groupKey, () => []).add(subcategory);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 32.h, bottom: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
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
                    child: Icon(Icons.close, color: AppColors.mainTeal),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('تصفية النتائج', textAlign: TextAlign.right, style: AppTextStyles.allCategoriesTitle),
              SizedBox(height: 8.h),
              Text(
                'حدد خياراتك للوصول إلى المنتجات المناسبة لك.',
                textAlign: TextAlign.right,
                style: AppTextStyles.allCategoriesSubtitle,
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final entry in _groupedSubcategories.entries) ...[
                        _FilterSection(
                          title: _groupTitles[entry.key] ?? entry.key,
                          children: [
                            for (final subcategory in entry.value)
                              _FilterChip(
                                label: subcategory.nameAr,
                                selected: _subcategorySlug == subcategory.slug,
                                onTap: () {
                                  setState(() {
                                    _subcategorySlug = _subcategorySlug == subcategory.slug
                                        ? null
                                        : subcategory.slug;
                                  });
                                  _onSelectionChanged();
                                },
                              ),
                          ],
                        ),
                        if (entry.key != _groupedSubcategories.keys.last ||
                            widget.dosageForms.isNotEmpty)
                          const _SectionDivider(),
                      ],
                      if (widget.dosageForms.isNotEmpty)
                        _FilterSection(
                          title: 'شكل الدواء',
                          children: [
                            for (final form in widget.dosageForms)
                              _FilterChip(
                                label: form,
                                selected: _dosageForm == form,
                                onTap: () {
                                  setState(() => _dosageForm = _dosageForm == form ? null : form);
                                  _onSelectionChanged();
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              AppCustomButton(
                text: _isCounting ? 'عرض النتائج...' : 'عرض النتائج ($_resultCount)',
                onPressed: () => Navigator.of(context).pop(
                  CategoryFilterResult(subcategorySlug: _subcategorySlug, dosageForm: _dosageForm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, textAlign: TextAlign.right, style: AppTextStyles.profileFieldLabel),
        SizedBox(height: 10.h),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.w,
          runSpacing: 10.h,
          children: children,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 33.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainTeal : AppColors.permissionIconBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.onboardingText,
          ),
        ),
      ),
    );
  }
}
