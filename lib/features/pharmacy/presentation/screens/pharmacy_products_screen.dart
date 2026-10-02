import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/medicine.dart';
import '../cubit/pharmacy_medicines_cubit.dart';
import '../cubit/pharmacy_medicines_state.dart';
import '../widgets/pharmacy_dashboard_tab_scope.dart';
import '../widgets/pharmacy_products_header.dart';
import '../widgets/product_action_card.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_chips.dart';
import '../widgets/product_search_field.dart';

/// "اجمالي المنتجات": the pharmacy's medicines, opened from the الرئيسية card
/// of the same name. A search box, stock filters, the two actions for adding
/// and updating, and a card per medicine whose stepper changes its stock.
///
/// Expects a [PharmacyMedicinesCubit] above it. It is a page of the shell, not
/// a tab of its own: the bottom bar keeps الرئيسية marked, and the back chip
/// returns there.
class PharmacyProductsScreen extends StatelessWidget {
  const PharmacyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PharmacyMedicinesCubit, PharmacyMedicinesState>(
        listenWhen: (previous, current) {
          final previousError = previous is PharmacyMedicinesLoaded ? previous.stockError : null;
          final currentError = current is PharmacyMedicinesLoaded ? current.stockError : null;
          return currentError != null && currentError != previousError;
        },
        listener: (context, state) {
          AppSnackbar.show(context, (state as PharmacyMedicinesLoaded).stockError!);
        },
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 0),
                sliver: SliverToBoxAdapter(
                  child: PharmacyProductsHeader(
                    onBack: () => PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                      context,
                      PharmacyDashboardTab.home,
                    ),
                  ),
                ),
              ),
              const _Body(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Everything under the header, by what the cubit is doing. Only a change of
/// phase rebuilds it: the search, the chips and the list each follow the state
/// themselves.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacyMedicinesCubit, PharmacyMedicinesState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || current is PharmacyMedicinesLoadFailure,
      builder: (context, state) {
        return switch (state) {
          PharmacyMedicinesLoading() => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          PharmacyMedicinesLoadFailure(:final message) => SliverFillRemaining(
            hasScrollBody: false,
            child: ProfileLoadError(
              message: message,
              onRetry: () => context.read<PharmacyMedicinesCubit>().load(),
            ),
          ),
          PharmacyMedicinesLoaded() => SliverPadding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
            sliver: const SliverMainAxisGroup(
              slivers: [SliverToBoxAdapter(child: _Controls()), _ProductList()],
            ),
          ),
        };
      },
    );
  }
}

/// The search box, the filter chips and the two action cards.
class _Controls extends StatelessWidget {
  const _Controls();

  Future<void> _openAddMedicine(BuildContext context) async {
    final added = await Navigator.of(context).pushNamed(Routes.addPharmacyMedicineScreen);
    if (added == true && context.mounted) {
      context.read<PharmacyMedicinesCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PharmacyMedicinesCubit>();
    final state = cubit.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 24 under the header's last line; its box ends 3 below where the
        // line reads.
        SizedBox(height: 21.h),
        ProductSearchField(
          initialText: state is PharmacyMedicinesLoaded ? state.query : '',
          onChanged: cubit.queryChanged,
        ),
        SizedBox(height: 16.h),
        BlocSelector<
          PharmacyMedicinesCubit,
          PharmacyMedicinesState,
          ({int total, MedicineStatusFilter filter})
        >(
          selector: (state) => state is PharmacyMedicinesLoaded
              ? (total: state.medicines.length, filter: state.filter)
              : (total: 0, filter: MedicineStatusFilter.all),
          builder: (context, chips) => ProductFilterChips(
            totalCount: chips.total,
            selected: chips.filter,
            onSelected: cubit.filterChanged,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ProductActionCard(
                label: 'أضف منتج جديد',
                onTap: () => _openAddMedicine(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ProductActionCard(
                label: 'تحديث المنتجات',
                // Updating stock in bulk is what the inventory page does.
                onTap: () => PharmacyDashboardTabScope.switchToTabOrShowComingSoon(
                  context,
                  PharmacyDashboardTab.inventory,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

/// A card per medicine that matches the search and the filter — or a line
/// saying why there is none.
class _ProductList extends StatelessWidget {
  const _ProductList();

  Future<void> _openEditMedicine(BuildContext context, Medicine medicine) async {
    final edited = await Navigator.of(
      context,
    ).pushNamed(Routes.editPharmacyMedicineScreen, arguments: medicine);
    if (edited == true && context.mounted) {
      context.read<PharmacyMedicinesCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PharmacyMedicinesCubit>();

    return BlocBuilder<PharmacyMedicinesCubit, PharmacyMedicinesState>(
      buildWhen: (previous, current) => current is PharmacyMedicinesLoaded,
      builder: (context, state) {
        if (state is! PharmacyMedicinesLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final medicines = state.filteredMedicines;
        if (medicines.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 32.h),
              child: Text(
                state.medicines.isEmpty ? 'لا توجد منتجات بعد' : 'لا توجد منتجات مطابقة',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardDescription,
              ),
            ),
          );
        }

        return SliverList.separated(
          itemCount: medicines.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final medicine = medicines[index];
            return ProductCard(
              key: ValueKey(medicine.id),
              medicine: medicine,
              quantity: state.quantityFor(medicine),
              status: state.statusFor(medicine),
              onTap: () => _openEditMedicine(context, medicine),
              onIncrement: () => cubit.increment(medicine),
              onDecrement: () => cubit.decrement(medicine),
            );
          },
        );
      },
    );
  }
}
