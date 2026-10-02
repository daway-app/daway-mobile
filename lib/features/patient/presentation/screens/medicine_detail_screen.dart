import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/header_icon_button.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/medicine_detail.dart';
import '../../domain/entities/medicine_pharmacy_offer.dart';
import '../cubit/availability_alert_cubit.dart';
import '../cubit/availability_alert_state.dart';
import '../cubit/medicine_detail_cubit.dart';
import '../cubit/medicine_detail_state.dart';
import '../widgets/medicine_pharmacy_option_card.dart';

/// "صفحة المنتج" — a medicine's detail: its image, name, use tags, and the
/// pharmacies stocking it (radio-selectable — the current pick is what
/// "أضف الى السلة" adds).
class MedicineDetailScreen extends StatelessWidget {
  final int medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicineDetailCubit>(param1: medicineId),
      child: const _MedicineDetailView(),
    );
  }
}

class _MedicineDetailView extends StatelessWidget {
  const _MedicineDetailView();

  Future<void> _toggleFavorite(BuildContext context) async {
    final error = await context.read<MedicineDetailCubit>().toggleFavorite();
    if (error != null && context.mounted) {
      AppSnackbar.show(context, error);
    }
  }

  Future<void> _addToCart(
    BuildContext context,
    MedicinePharmacyOffer? offer,
  ) async {
    if (offer == null) {
      AppSnackbar.show(context, 'لا توجد صيدلية متوفرة للإضافة إلى السلة');
      return;
    }
    final error = await context.read<MedicineDetailCubit>().addToCart(offer);
    if (!context.mounted) return;
    if (error != null) {
      AppSnackbar.show(context, error);
      return;
    }
    AppSnackbar.show(context, 'تمت إضافة الدواء إلى السلة');
    Navigator.of(context).pushNamed(Routes.patientCartScreen);
  }

  void _askPharmacy(
    BuildContext context,
    MedicinePharmacyOffer? offer,
    MedicineDetail medicine,
  ) {
    if (offer == null) {
      AppSnackbar.show(context, 'لا توجد صيدلية متوفرة لإرسال الاستفسار');
      return;
    }
    Navigator.of(context).pushNamed(
      Routes.chatScreen,
      arguments: {
        'pharmacyId': offer.pharmacyId,
        'medicineId': medicine.id,
        'title': offer.pharmacyName,
        'subtitle': medicine.tradeName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MedicineDetailCubit, MedicineDetailState>(
          builder: (context, state) {
            return switch (state) {
              MedicineDetailLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              MedicineDetailLoadFailure(:final message) => ProfileLoadError(
                message: message,
                onRetry: () => context.read<MedicineDetailCubit>().load(),
              ),
              MedicineDetailLoaded() => _MedicineDetailContent(
                state: state,
                onBackTap: () => Navigator.of(context).maybePop(),
                onFavoriteTap: () => _toggleFavorite(context),
                onAddToCartTap: (offer) => _addToCart(context, offer),
                onAskPharmacyTap: (offer) =>
                    _askPharmacy(context, offer, state.medicine),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _MedicineDetailContent extends StatefulWidget {
  final MedicineDetailLoaded state;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;
  final ValueChanged<MedicinePharmacyOffer?> onAddToCartTap;
  final ValueChanged<MedicinePharmacyOffer?> onAskPharmacyTap;

  const _MedicineDetailContent({
    required this.state,
    required this.onBackTap,
    required this.onFavoriteTap,
    required this.onAddToCartTap,
    required this.onAskPharmacyTap,
  });

  @override
  State<_MedicineDetailContent> createState() => _MedicineDetailContentState();
}

class _MedicineDetailContentState extends State<_MedicineDetailContent> {
  // Which pharmacy card is highlighted — purely local UI state (CLAUDE.md
  // B1: setState is for exactly this), not something any use case reads yet.
  int? _selectedPharmacyId;

  @override
  void initState() {
    super.initState();
    _syncSelection();
  }

  @override
  void didUpdateWidget(covariant _MedicineDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelection();
  }

  /// Defaults to the first pharmacy once the list loads, and keeps the
  /// current pick across unrelated rebuilds (e.g. toggling the favorite
  /// button) as long as it is still in the list.
  void _syncSelection() {
    final pharmacies = widget.state.pharmacies;
    if (pharmacies.isEmpty) {
      _selectedPharmacyId = null;
      return;
    }
    if (_selectedPharmacyId == null ||
        !pharmacies.any((offer) => offer.pharmacyId == _selectedPharmacyId)) {
      _selectedPharmacyId = pharmacies.first.pharmacyId;
    }
  }

  MedicinePharmacyOffer? get _selectedOffer {
    final pharmacies = widget.state.pharmacies;
    if (_selectedPharmacyId == null) return null;
    for (final offer in pharmacies) {
      if (offer.pharmacyId == _selectedPharmacyId) return offer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.state.medicine;
    final pharmacies = widget.state.pharmacies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MedicineImageHeader(
                  medicine: medicine,
                  isFavorite: widget.state.isFavorite,
                  isTogglingFavorite: widget.state.isTogglingFavorite,
                  onBackTap: widget.onBackTap,
                  onFavoriteTap: widget.onFavoriteTap,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      Text(
                        medicine.tradeName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.medicineDetailName,
                      ),
                      if (medicine.tags.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _MedicineTagsRow(tags: medicine.tags),
                      ],
                      SizedBox(height: 24.h),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.productDetailDivider,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'اختر الصيدلية المناسبة لك',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.medicineDetailSectionLabel,
                      ),
                      SizedBox(height: 16.h),
                      if (pharmacies.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Column(
                            children: [
                              Text(
                                'لا توجد صيدليات متوفرة لهذا الدواء حالياً',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.homePharmacyCardSubtitle,
                              ),
                              SizedBox(height: 12.h),
                              _AvailabilityAlertButton(medicineId: medicine.id),
                            ],
                          ),
                        )
                      else
                        for (final offer in pharmacies) ...[
                          MedicinePharmacyOptionCard(
                            offer: offer,
                            selected: offer.pharmacyId == _selectedPharmacyId,
                            onTap: () => setState(
                              () => _selectedPharmacyId = offer.pharmacyId,
                            ),
                          ),
                          if (offer != pharmacies.last) SizedBox(height: 24.h),
                        ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Pinned to the bottom of the screen, outside the scrolling area.
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
          child: _BottomActionsRow(
            onAddToCartTap: () => widget.onAddToCartTap(_selectedOffer),
            onAskPharmacyTap: () => widget.onAskPharmacyTap(_selectedOffer),
          ),
        ),
      ],
    );
  }
}

/// "نبّهني عند التوفر" — subscribes the patient to a notification for this
/// medicine; own cubit so the detail cubit and its tests stay untouched.
class _AvailabilityAlertButton extends StatelessWidget {
  final int medicineId;

  const _AvailabilityAlertButton({required this.medicineId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AvailabilityAlertCubit>(param1: medicineId),
      child: BlocBuilder<AvailabilityAlertCubit, AvailabilityAlertState>(
        builder: (context, state) {
          final subscribed = state is AvailabilityAlertSubscribed;
          return TextButton.icon(
            onPressed: state is AvailabilityAlertIdle
                ? () async {
                    final error = await context
                        .read<AvailabilityAlertCubit>()
                        .subscribe();
                    if (context.mounted) {
                      AppSnackbar.show(
                        context,
                        error ?? 'سنخبرك عند توفر الدواء',
                      );
                    }
                  }
                : null,
            icon: Icon(
              subscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: AppColors.mainTeal,
            ),
            label: Text(
              subscribed ? 'سنخبرك عند التوفر' : 'نبّهني عند التوفر',
              style: TextStyle(color: AppColors.mainTeal),
            ),
          );
        },
      ),
    );
  }
}

class _MedicineImageHeader extends StatelessWidget {
  final MedicineDetail medicine;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;

  const _MedicineImageHeader({
    required this.medicine,
    required this.isFavorite,
    required this.isTogglingFavorite,
    required this.onBackTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = medicine.imageUrl;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 282.h,
          color: AppColors.background,
          alignment: Alignment.center,
          child: (imageUrl != null && imageUrl.isNotEmpty)
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.medication_outlined,
                    size: 64.sp,
                    color: AppColors.mainTeal,
                  ),
                )
              : Icon(
                  Icons.medication_outlined,
                  size: 64.sp,
                  color: AppColors.mainTeal,
                ),
        ),
        Positioned(
          top: 32.h,
          right: 24.w,
          child: HeaderIconButton(
            assetName: 'assets/icons/back_icon.svg',
            iconSize: 24,
            backgroundColor: AppColors.accountIconBg,
            iconColor: AppColors.mainTeal,
            semanticLabel: 'رجوع',
            onTap: onBackTap,
          ),
        ),
        Positioned(
          top: 32.h,
          left: 24.w,
          child: isTogglingFavorite
              ? Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.iconBlueBorder),
                  ),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : HeaderIconButton(
                  // Filled once saved, the plain outline otherwise — the
                  // detail endpoint has no "already saved" field (see
                  // MedicineDetailLoaded.isFavorite), so this only ever
                  // reflects a toggle made on this screen, not history.
                  assetName: isFavorite
                      ? 'assets/icons/bookmark_filled_icon.svg'
                      : 'assets/icons/bookmark_icon.svg',
                  iconSize: 20,
                  semanticLabel: isFavorite
                      ? 'إزالة من المحفوظات'
                      : 'حفظ في المفضلة',
                  onTap: onFavoriteTap,
                ),
        ),
      ],
    );
  }
}

class _MedicineTagsRow extends StatelessWidget {
  final List<String> tags;

  const _MedicineTagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    const maxVisible = 3;
    final visible = tags.take(maxVisible).toList();
    final overflow = tags.length - visible.length;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final tag in visible) _TagChip(label: tag),
        if (overflow > 0) _TagChip(label: '+$overflow'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.permissionIconBg,
        border: Border.all(color: AppColors.iconBlueBorder),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label, style: AppTextStyles.medicineDetailTag),
    );
  }
}

class _BottomActionsRow extends StatelessWidget {
  final VoidCallback onAddToCartTap;
  final VoidCallback onAskPharmacyTap;

  const _BottomActionsRow({
    required this.onAddToCartTap,
    required this.onAskPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The design dropped the separate cart-icon shortcut that used to
        // sit beside this button — the home header's cart icon is still
        // there, so nothing is unreachable, just less cluttered here.
        AppCustomButton(text: 'أضف الى السلة', onPressed: onAddToCartTap),
        SizedBox(height: 16.h),
        // "اسأل الصيدلية قبل الشراء" — opens MedicineInquiryScreen for the
        // selected pharmacy + this medicine (see PharmacyInquiry's doc
        // comment: one question, one reply, not a live chat).
        AppCustomButton(
          text: 'اسأل الصيدلية قبل الشراء',
          backgroundColor: Colors.white,
          textColor: AppColors.onboardingText,
          borderColor: AppColors.iconBlueBorder,
          fontWeight: FontWeight.w500,
          onPressed: onAskPharmacyTap,
        ),
      ],
    );
  }
}
