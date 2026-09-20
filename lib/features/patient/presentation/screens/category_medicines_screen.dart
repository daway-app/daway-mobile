import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_medicine.dart';
import '../../domain/entities/category_subcategory.dart';
import '../cubit/category_medicines_cubit.dart';
import '../cubit/category_medicines_state.dart';
import 'category_filter_screen.dart';
import '../widgets/category_medicine_card.dart';
import '../widgets/category_symptom_grid.dart';
import '../widgets/patient_bottom_nav_bar.dart';
import '../widgets/patient_dashboard_tab_scope.dart';

class CategoryMedicinesScreen extends StatelessWidget {
  final Category category;

  const CategoryMedicinesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryMedicinesCubit>(param1: category),
      child: _CategoryMedicinesView(category: category),
    );
  }
}

class _CategoryMedicinesView extends StatefulWidget {
  final Category category;

  const _CategoryMedicinesView({required this.category});

  @override
  State<_CategoryMedicinesView> createState() => _CategoryMedicinesViewState();
}

class _CategoryMedicinesViewState extends State<_CategoryMedicinesView> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<CategorySubcategory> get _symptomSubcategories => widget.category.subcategories
      .where((subcategory) => subcategory.groupKey == 'symptoms')
      .toList();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200.h;
    if (_scrollController.position.pixels >= threshold) {
      context.read<CategoryMedicinesCubit>().loadMore();
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<CategoryMedicinesCubit>().search(value);
    });
  }

  bool _isLandingMode(CategoryMedicinesState state) {
    return _symptomSubcategories.isNotEmpty &&
        state is CategoryMedicinesLoaded &&
        !state.hasActiveFilters &&
        state.query.isEmpty;
  }

  Future<void> _openFilterSheet(CategoryMedicinesLoaded state) async {
    final cubit = context.read<CategoryMedicinesCubit>();
    final result = await showCategoryFilterScreen(
      context,
      cubit: cubit,
      subcategories: widget.category.subcategories,
      dosageForms: state.dosageForms,
      initialSubcategorySlug: state.subcategorySlug,
      initialDosageForm: state.dosageForm,
      initialTotal: state.total,
    );
    if (result != null) {
      cubit.applyFilters(subcategorySlug: result.subcategorySlug, dosageForm: result.dosageForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PatientBottomNavBar(
        selectedTab: PatientDashboardTab.home,
        onTabSelected: (tab) {
          Navigator.of(context).pop();
          PatientDashboardTabScope.maybeOf(context)?.switchToTab(tab);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),
              _Header(category: widget.category),
              SizedBox(height: 20.h),
              BlocBuilder<CategoryMedicinesCubit, CategoryMedicinesState>(
                builder: (context, state) {
                  return _SearchField(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                    onFilterTap: state is CategoryMedicinesLoaded && !_isLandingMode(state)
                        ? () => _openFilterSheet(state)
                        : null,
                  );
                },
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: BlocBuilder<CategoryMedicinesCubit, CategoryMedicinesState>(
                  builder: (context, state) {
                    return switch (state) {
                      CategoryMedicinesLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      CategoryMedicinesLoadFailure(:final message) => Center(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.homePharmacyCardSubtitle,
                          ),
                        ),
                      CategoryMedicinesLoaded(:final medicines) when medicines.isEmpty => Center(
                          child: Text(
                            'لا توجد أدوية مطابقة حالياً',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.homePharmacyCardSubtitle,
                          ),
                        ),
                      CategoryMedicinesLoaded loaded when _isLandingMode(loaded) =>
                        _SymptomLandingView(
                          symptoms: _symptomSubcategories,
                          medicines: loaded.medicines,
                          onSymptomTap: (symptom) => context
                              .read<CategoryMedicinesCubit>()
                              .applyFilters(subcategorySlug: symptom.slug),
                        ),
                      CategoryMedicinesLoaded loaded => _MedicinesGrid(
                          state: loaded,
                          scrollController: _scrollController,
                        ),
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

class _Header extends StatelessWidget {
  final Category category;

  const _Header({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(category.nameAr, textAlign: TextAlign.right, style: AppTextStyles.allCategoriesTitle),
        SizedBox(height: 8.h),
        Text(
          'تصفح كل خيارات ${category.nameAr} المتوفرة لدينا.',
          textAlign: TextAlign.right,
          style: AppTextStyles.allCategoriesSubtitle,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const _SearchField({required this.controller, required this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/Search_icon.svg',
                  width: 18.w,
                  height: 18.w,
                  colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.homeSearchHint.copyWith(color: AppColors.onboardingText),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'ابحث عن دواء او اكتب بماذا تشعر',
                      hintStyle: AppTextStyles.homeSearchHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          SizedBox(width: 24.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 56.w,
              height: 56.w,
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.accountIconBg,
                border: Border.all(color: AppColors.iconBlueBorder),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SvgPicture.asset(
                'assets/icons/filter_icon.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(AppColors.mainTeal, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SymptomLandingView extends StatelessWidget {
  final List<CategorySubcategory> symptoms;
  final List<CategoryMedicine> medicines;
  final ValueChanged<CategorySubcategory> onSymptomTap;

  const _SymptomLandingView({
    required this.symptoms,
    required this.medicines,
    required this.onSymptomTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('بماذا تشعر', textAlign: TextAlign.right, style: AppTextStyles.categorySectionTitle),
          SizedBox(height: 16.h),
          CategorySymptomGrid(symptoms: symptoms, onSymptomTap: onSymptomTap),
          if (medicines.isNotEmpty) ...[
            SizedBox(height: 32.h),
            Text('أدوية قد تعالجها', textAlign: TextAlign.right, style: AppTextStyles.categorySectionTitle),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicines.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24.w,
                mainAxisSpacing: 24.h,
                childAspectRatio: 184 / 201,
              ),
              itemBuilder: (context, index) => CategoryMedicineCard(
                medicine: medicines[index],
                onDetailsTap: () => AppSnackbar.show(context, 'قريباً'),
              ),
            ),
          ],
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _MedicinesGrid extends StatelessWidget {
  final CategoryMedicinesLoaded state;
  final ScrollController scrollController;

  const _MedicinesGrid({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: state.medicines.length + (state.hasMorePages ? 1 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24.w,
        mainAxisSpacing: 24.h,
        childAspectRatio: 184 / 201,
      ),
      itemBuilder: (context, index) {
        if (index >= state.medicines.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return CategoryMedicineCard(
          medicine: state.medicines[index],
          onDetailsTap: () => AppSnackbar.show(context, 'قريباً'),
        );
      },
    );
  }
}
