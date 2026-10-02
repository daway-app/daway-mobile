import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/picked_location.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/patient_sub_screen_header.dart';

/// "السلة" — reads/updates the real `/patient/cart` backend. Adding items
/// still happens elsewhere (currently nowhere: see MedicineDetailScreen's
/// doc comment on why "أضف الى السلة" is "قريباً" for now).
class PatientCartScreen extends StatelessWidget {
  const PatientCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<CheckoutCubit>()),
      ],
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  void _browseCategories(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.allCategoriesScreen);
  }

  Future<void> _pickLocationAndSubmit(BuildContext context) async {
    final cubit = context.read<CheckoutCubit>();
    final location = await Navigator.of(context).pushNamed<PickedLocation>(
      Routes.locationPickerScreen,
    );
    if (location == null) return;
    await cubit.submitWithNewAddress(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                switch (state) {
                  case CheckoutNeedsAddress():
                    _pickLocationAndSubmit(context);
                  case CheckoutSuccess():
                    AppSnackbar.show(context, 'تم إنشاء طلبك بنجاح');
                    context.read<CartCubit>().load();
                  case CheckoutFailure(:final message):
                    AppSnackbar.show(context, message);
                  case CheckoutIdle():
                  case CheckoutInProgress():
                }
              },
            ),
          ],
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: const PatientSubScreenHeader(
                      title: 'السلة',
                      description: 'راجع منتجاتك وتأكد من تفاصيل طلبك قبل الدفع.',
                    ),
                  ),
                  Expanded(
                    child: switch (state) {
                      CartLoading() => const Center(child: CircularProgressIndicator()),
                      CartLoadFailure(:final message) => ProfileLoadError(
                          message: message,
                          onRetry: () => context.read<CartCubit>().load(),
                        ),
                      CartLoaded(:final items) when items.isEmpty =>
                        _EmptyCart(onBrowseTap: () => _browseCategories(context)),
                      CartLoaded() => _CartList(state: state),
                    },
                  ),
                  if (state is CartLoaded && state.items.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                      child: BlocBuilder<CheckoutCubit, CheckoutState>(
                        builder: (context, checkoutState) {
                          return AppCustomButton(
                            text: 'إتمام الطلب',
                            isLoading: checkoutState is CheckoutInProgress,
                            onPressed: () => context.read<CheckoutCubit>().start(),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  final CartLoaded state;

  const _CartList({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          for (final item in state.items) ...[
            // Swipe a line away to remove it; the row only disappears once
            // the server confirms (confirmDismiss), so a failed delete
            // springs back with a message.
            Dismissible(
              key: ValueKey('cartItem_${item.id}'),
              direction: DismissDirection.horizontal,
              confirmDismiss: (_) async {
                final error = await cubit.deleteItem(item);
                if (error != null && context.mounted) AppSnackbar.show(context, error);
                return false;
              },
              background: const _DeleteBackground(),
              child: CartItemCard(
                item: item,
                isUpdating: state.updatingIds.contains(item.id),
                onIncrement: () => cubit.incrementQuantity(item),
                onDecrement: () => cubit.decrementQuantity(item),
              ),
            ),
            SizedBox(height: 24.h),
          ],
          SizedBox(height: 8.h),
          Text(
            'الاجمالي للمنتجات : ${_formatTotal(state.total)} \$',
            textAlign: TextAlign.right,
            style: AppTextStyles.profileFieldLabel,
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final error = await cubit.clear();
                if (error != null && context.mounted) AppSnackbar.show(context, error);
              },
              child: Text('تفريغ السلة', style: TextStyle(color: AppColors.logoutRed)),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  String _formatTotal(double total) =>
      total == total.roundToDouble() ? total.toStringAsFixed(0) : total.toStringAsFixed(2);
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.logoutRedTint,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.delete_outline, color: AppColors.logoutRed, size: 24.sp),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowseTap;

  const _EmptyCart({required this.onBrowseTap});

  @override
  Widget build(BuildContext context) {
    // No illustration asset for this state yet (the design's "سلتك فاضية"
    // image isn't in assets/images) — an icon stands in until one is added.
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64.sp, color: AppColors.grey),
            SizedBox(height: 24.h),
            Text('سلتك فاضية', style: AppTextStyles.emptyStateTitle),
            SizedBox(height: 16.h),
            Text(
              'أضف المنتجات اللي بدك إياها وابدأ طلبك بسهولة',
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyStateSubtitle,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onBrowseTap,
              child: Container(
                height: 33.h,
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.permissionIconBg,
                  border: Border.all(color: AppColors.iconBlueBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text('تصفح الأقسام', style: AppTextStyles.emptyStateAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
