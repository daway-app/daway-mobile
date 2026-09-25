import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/searched_medicine.dart';
import '../cubit/medicine_search_cubit.dart';
import '../cubit/medicine_search_state.dart';
import '../widgets/searched_medicine_card.dart';

/// Static fallback for "الأكثر بحثاً" — there's no trending/popular-search
/// endpoint yet, so this is a fixed editorial list rather than real
/// analytics. Swap for a real usecase call once the backend adds one.
const _trendingSearches = [
  'بانادول',
  'فيتامين C',
  'دواء للمعدة',
  'أكامول',
  'مضاد حيوي',
  'مسكن ألم موضعي',
  'فيتامين D',
  'مسكنات الألم',
];

/// Home tab's "البحث" search screen. Has no Scaffold/AppBar/Drawer of its
/// own, same as [PatientHomeScreen] — it's a top-level dashboard tab, and
/// the shell already supplies the bottom nav.
class MedicineSearchScreen extends StatelessWidget {
  const MedicineSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicineSearchCubit>(),
      child: const _MedicineSearchView(),
    );
  }
}

class _MedicineSearchView extends StatefulWidget {
  const _MedicineSearchView();

  @override
  State<_MedicineSearchView> createState() => _MedicineSearchViewState();
}

class _MedicineSearchViewState extends State<_MedicineSearchView> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<MedicineSearchCubit>().search(value);
    });
  }

  void _searchTerm(String term) {
    _debounce?.cancel();
    _searchController.text = term;
    _searchController.selection = TextSelection.collapsed(offset: term.length);
    context.read<MedicineSearchCubit>().search(term);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchField(controller: _searchController, onChanged: _onQueryChanged),
            SizedBox(height: 24.h),
            Expanded(
              child: BlocBuilder<MedicineSearchCubit, MedicineSearchState>(
                builder: (context, state) {
                  return switch (state) {
                    MedicineSearchIdle() =>
                      _TrendingSearches(onTermTap: _searchTerm),
                    MedicineSearchLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    MedicineSearchLoadFailure(:final message) => Center(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.homePharmacyCardSubtitle,
                        ),
                      ),
                    MedicineSearchLoaded(:final results) when results.isEmpty => Center(
                        child: Text(
                          'لا توجد نتائج مطابقة',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.homePharmacyCardSubtitle,
                        ),
                      ),
                    MedicineSearchLoaded(:final results) => _SearchResultsGrid(results: results),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                hintText: 'ابحث عن احتياجك',
                hintStyle: AppTextStyles.homeSearchHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingSearches extends StatelessWidget {
  final ValueChanged<String> onTermTap;

  const _TrendingSearches({required this.onTermTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('الأكثر بحثاً', textAlign: TextAlign.right, style: AppTextStyles.searchSectionTitle),
          for (var i = 0; i < _trendingSearches.length; i++)
            _TrendingSearchRow(
              term: _trendingSearches[i],
              showDivider: i < _trendingSearches.length - 1,
              onTap: () => onTermTap(_trendingSearches[i]),
            ),
        ],
      ),
    );
  }
}

class _TrendingSearchRow extends StatelessWidget {
  final String term;
  final bool showDivider;
  final VoidCallback onTap;

  const _TrendingSearchRow({
    required this.term,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.searchTermDivider),
                ),
              )
            : null,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/image_icon.svg',
              width: 32.w,
              height: 32.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                term,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.searchTermText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final List<SearchedMedicine> results;

  const _SearchResultsGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: results.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24.w,
        mainAxisSpacing: 24.h,
        childAspectRatio: 184 / 201,
      ),
      itemBuilder: (context, index) => SearchedMedicineCard(
        medicine: results[index],
        onDetailsTap: () => AppSnackbar.show(context, 'قريباً'),
      ),
    );
  }
}
