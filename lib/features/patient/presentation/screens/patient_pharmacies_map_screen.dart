import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/header_icon_button.dart';
import '../../../../core/widgets/profile_load_error.dart';
import '../../domain/entities/nearby_pharmacy.dart';
import '../cubit/nearby_pharmacies_cubit.dart';
import '../cubit/nearby_pharmacies_state.dart';

/// "اكتشف الصيدليات القريبة منك" from the home screen — a live map (see
/// LocationPickerScreen for the same google_maps_flutter setup) with a
/// marker per pharmacy; tapping one (or the map) opens/closes its detail
/// sheet.
class PatientPharmaciesMapScreen extends StatelessWidget {
  const PatientPharmaciesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NearbyPharmaciesCubit>(),
      child: const _PharmaciesMapView(),
    );
  }
}

class _PharmaciesMapView extends StatefulWidget {
  const _PharmaciesMapView();

  @override
  State<_PharmaciesMapView> createState() => _PharmaciesMapViewState();
}

class _PharmaciesMapViewState extends State<_PharmaciesMapView> {
  late final TextEditingController _searchController;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _openChat(BuildContext context, NearbyPharmacy pharmacy) {
    Navigator.of(context).pushNamed(
      Routes.chatScreen,
      arguments: {'pharmacyId': pharmacy.id, 'title': pharmacy.name},
    );
  }

  Future<void> _call(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      AppSnackbar.show(context, 'رقم الهاتف غير متوفر');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      if (context.mounted) AppSnackbar.show(context, 'تعذر فتح تطبيق الاتصال');
    }
  }

  Future<void> _openDirections(BuildContext context, NearbyPharmacy pharmacy) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) AppSnackbar.show(context, 'تعذر فتح تطبيق الخرائط');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NearbyPharmaciesCubit, NearbyPharmaciesState>(
        builder: (context, state) {
          return switch (state) {
            NearbyPharmaciesLoading() => const Center(child: CircularProgressIndicator()),
            NearbyPharmaciesLoadFailure(:final message) => ProfileLoadError(
                message: message,
                onRetry: () => context.read<NearbyPharmaciesCubit>().load(),
              ),
            NearbyPharmaciesLoaded() => _MapContent(
                state: state,
                searchController: _searchController,
                onMapCreated: (controller) => _mapController = controller,
                onMessageTap: (pharmacy) => _openChat(context, pharmacy),
                onCallTap: (phone) => _call(context, phone),
                onDirectionsTap: (pharmacy) => _openDirections(context, pharmacy),
              ),
          };
        },
      ),
    );
  }
}

class _MapContent extends StatelessWidget {
  final NearbyPharmaciesLoaded state;
  final TextEditingController searchController;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<NearbyPharmacy> onMessageTap;
  final ValueChanged<String?> onCallTap;
  final ValueChanged<NearbyPharmacy> onDirectionsTap;

  const _MapContent({
    required this.state,
    required this.searchController,
    required this.onMapCreated,
    required this.onMessageTap,
    required this.onCallTap,
    required this.onDirectionsTap,
  });

  /// The patient's own position, unless the nearest pharmacy is more than
  /// 50 km away (or the position is unknown) — then the nearest pharmacy, so
  /// the map never opens on an empty stretch of the world with no markers.
  LatLng _initialTarget() {
    final pharmacies = state.pharmacies;
    final nearest = pharmacies.isEmpty ? null : pharmacies.first;
    final userLat = state.userLatitude;
    final userLng = state.userLongitude;
    if (userLat != null && userLng != null) {
      final nearestKm = nearest?.distanceKm;
      if (nearest == null || (nearestKm != null && nearestKm <= 50)) {
        return LatLng(userLat, userLng);
      }
    }
    if (nearest != null) return LatLng(nearest.latitude, nearest.longitude);
    return LatLng(AppConstants.defaultMapLatitude, AppConstants.defaultMapLongitude);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NearbyPharmaciesCubit>();
    final selected = state.selectedPharmacy;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialTarget(),
            zoom: 14,
          ),
          onMapCreated: onMapCreated,
          myLocationEnabled: state.hasUserLocation,
          myLocationButtonEnabled: state.hasUserLocation,
          zoomControlsEnabled: false,
          onTap: (_) => cubit.clearSelection(),
          markers: {
            for (final pharmacy in state.visiblePharmacies)
              Marker(
                markerId: MarkerId('pharmacy_${pharmacy.id}'),
                position: LatLng(pharmacy.latitude, pharmacy.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                onTap: () => cubit.selectPharmacy(pharmacy),
              ),
          },
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 16.h, left: 24.w, right: 24.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // First child = right edge in this RTL layout.
                    HeaderIconButton(
                      assetName: 'assets/icons/back_icon.svg',
                      iconSize: 24,
                      backgroundColor: Colors.white,
                      iconColor: AppColors.mainTeal,
                      semanticLabel: 'رجوع',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                        child: AppTextField(
                          controller: searchController,
                          hintText: 'ابحث عن صيدلية',
                          textInputAction: TextInputAction.search,
                          onChanged: cubit.searchChanged,
                          icon: Icon(Icons.search, color: AppColors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.visiblePharmacies.isEmpty) ...[
                  SizedBox(height: 12.h),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Text(
                        'لا توجد صيدليات مطابقة لبحثك',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.emptyStateTitle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PharmacyDetailSheet(
              pharmacy: selected,
              isLoadingHours: state.isLoadingHours,
              workingHoursLabel: state.selectedWorkingHours,
              onMessageTap: () => onMessageTap(selected),
              onCallTap: () => onCallTap(selected.phoneNumber),
              onDirectionsTap: () => onDirectionsTap(selected),
            ),
          ),
      ],
    );
  }
}

class _PharmacyDetailSheet extends StatelessWidget {
  final NearbyPharmacy pharmacy;
  final bool isLoadingHours;
  final String? workingHoursLabel;
  final VoidCallback onMessageTap;
  final VoidCallback onCallTap;
  final VoidCallback onDirectionsTap;

  const _PharmacyDetailSheet({
    required this.pharmacy,
    required this.isLoadingHours,
    required this.workingHoursLabel,
    required this.onMessageTap,
    required this.onCallTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = pharmacy.distanceKm;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 321.h),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  pharmacy.name,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pharmacySheetName,
                ),
              ),
              if (distanceKm != null) ...[
                SizedBox(width: 12.w),
                _Badge(
                  width: 86,
                  label: 'يبعد عنك ${distanceKm.toStringAsFixed(1)} كم',
                  background: AppColors.permissionIconBg,
                  border: AppColors.iconBlueBorder,
                  textColor: AppColors.mainTeal,
                ),
              ],
              SizedBox(width: 8.w),
              _Badge(
                width: 60,
                label: pharmacy.isOpenNow ? 'مفتوح الان' : 'مغلق الان',
                background: pharmacy.isOpenNow ? AppColors.pharmacyOpenBg : AppColors.logoutRedTint,
                textColor: pharmacy.isOpenNow ? AppColors.pharmacyOpenText : AppColors.logoutRed,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (isLoadingHours)
            const Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (workingHoursLabel != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'مواعيد العمل  ', style: AppTextStyles.pharmacySheetHoursLabel),
                  TextSpan(text: workingHoursLabel, style: AppTextStyles.pharmacySheetHoursValue),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _OutlineActionButton(
                  icon: Icons.call_outlined,
                  label: 'اتصال',
                  onTap: onCallTap,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _OutlineActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'مراسلة',
                  onTap: onMessageTap,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          AppCustomButton(text: 'عرض الاتجاهات', onPressed: onDirectionsTap),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final double width;
  final String label;
  final Color background;
  final Color? border;
  final Color textColor;

  const _Badge({
    required this.width,
    required this.label,
    required this.background,
    this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: 22.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4.r),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.pharmacySheetBadge.copyWith(color: textColor),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.permissionIconBg,
          border: Border.all(color: AppColors.iconBlueBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppColors.mainTeal),
            SizedBox(width: 8.w),
            Text(label, style: AppTextStyles.pharmacySheetHoursLabel.copyWith(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
