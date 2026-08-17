import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/models/picked_location.dart';
import '../cubit/location_picker_cubit.dart';
import '../cubit/location_picker_state.dart';
import '../widgets/location_search_bar.dart';

/// Interactive map with a pin fixed at the screen center — the user drags
/// the map underneath it, rather than dragging a marker. Returns the picked
/// [PickedLocation] to the caller via [Navigator.pop].
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final TextEditingController _searchController;
  GoogleMapController? _mapController;
  LocationPickerState? _previousState;

  // True while the camera is moving because *we* told it to (the initial
  // placement, or animateCamera() after useCurrentLocation()/search()
  // already resolved a position+address) rather than because the user
  // dragged the map. The idle event a programmatic move produces must not
  // re-run reverse geocoding — the address is already correct — and starts
  // true so the very first idle (right after the map renders its initial
  // position) is treated the same way. It is only ever set by the listener
  // (never inside _onCameraIdle itself), so a genuine drag can't race with it.
  bool _isProgrammaticCameraMove = true;

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

  Future<void> _onCameraIdle() async {
    if (_isProgrammaticCameraMove) {
      _isProgrammaticCameraMove = false;
      return;
    }

    final controller = _mapController;
    if (controller == null) return;

    final bounds = await controller.getVisibleRegion();
    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
    if (!mounted) return;
    final cubit = context.read<LocationPickerCubit>();
    cubit.pinMoved(center.latitude, center.longitude);
    await cubit.resolveAddressForCurrentPin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('تحديد الموقع', style: AppTextStyles.screenTitle),
      ),
      body: BlocConsumer<LocationPickerCubit, LocationPickerState>(
        // Runs on every emission (not gated by listenWhen) so _previousState
        // always reflects the true prior state — needed to reliably detect
        // the isLocating/isSearching true→false transition below.
        listener: (context, state) {
          final previous = _previousState;
          _previousState = state;

          if (state.errorMessage != null && state.errorMessage != previous?.errorMessage) {
            AppSnackbar.show(context, state.errorMessage!);
          }

          // Only useCurrentLocation()/search() need the camera to jump —
          // pinMoved() (a drag) already reflects where the map physically is.
          final justFinishedLocating = (previous?.isLocating ?? false) && !state.isLocating;
          final justFinishedSearching = (previous?.isSearching ?? false) && !state.isSearching;
          if (justFinishedLocating || justFinishedSearching) {
            _isProgrammaticCameraMove = true;
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(state.latitude, state.longitude)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(state.latitude, state.longitude),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      onCameraIdle: _onCameraIdle,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 36.h),
                        child: Icon(
                          Icons.location_pin,
                          size: 44.sp,
                          color: AppColors.mainTeal,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      left: 16.w,
                      right: 16.w,
                      child: LocationSearchBar(controller: _searchController),
                    ),
                    Positioned(
                      bottom: 16.h,
                      left: 16.w,
                      child: FloatingActionButton(
                        heroTag: 'useCurrentLocation',
                        backgroundColor: Colors.white,
                        onPressed: () => context.read<LocationPickerCubit>().useCurrentLocation(),
                        child: state.isLocating
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : Icon(Icons.my_location, color: AppColors.mainTeal),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12.r,
                      offset: Offset(0, -2.h),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.mainTeal),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.isResolvingAddress
                                  ? 'جارِ تحديد العنوان...'
                                  : (state.address?.isNotEmpty == true
                                      ? state.address!
                                      : 'اسحب الخريطة لتحديد الموقع'),
                              style: AppTextStyles.authSubtitle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      AppCustomButton(
                        text: 'تأكيد الموقع',
                        isLoading: state.isResolvingAddress,
                        onPressed: () {
                          if (state.isResolvingAddress) return;
                          Navigator.of(context).pop(PickedLocation(
                            latitude: state.latitude,
                            longitude: state.longitude,
                            address: state.address ?? '',
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
