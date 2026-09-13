import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/pharmacy_sign_up_cubit.dart';
import '../cubit/pharmacy_sign_up_state.dart';
import '../widgets/location_permission_view.dart';
import 'pharmacy_notifications_permission_screen.dart';

/// Pushed by [PharmacySignUpForm] once the account-details step is
/// validated — mirrors [LocationPermissionScreen] from the patient flow via
/// the shared [LocationPermissionView].
///
/// Back navigation is left enabled (no `PopScope`) so a user whose location
/// permission is permanently denied still has a way out, back to the
/// previous step, instead of being stuck on this screen forever.
class PharmacyLocationPermissionScreen extends StatelessWidget {
  const PharmacyLocationPermissionScreen({super.key});

  void _continue(BuildContext context) {
    final cubit = context.read<PharmacySignUpCubit>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const PharmacyNotificationsPermissionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PharmacySignUpCubit, PharmacySignUpState>(
          listenWhen: (previous, current) =>
              (current.locationReady && !previous.locationReady) ||
              (current.locationError != null &&
                  previous.locationError != current.locationError),
          listener: (context, state) {
            if (state.locationReady) {
              _continue(context);
            } else if (state.locationError != null) {
              AppSnackbar.show(context, state.locationError!);
            }
          },
          child: BlocBuilder<PharmacySignUpCubit, PharmacySignUpState>(
            buildWhen: (previous, current) =>
                previous.isFetchingLocation != current.isFetchingLocation ||
                previous.locationError != current.locationError,
            builder: (context, state) {
              return LocationPermissionView(
                subtitle: 'فعّل موقعك لمساعدة المرضى في العثور على صيدليتك بسهولة.',
                buttonColor: AppColors.mainTeal,
                errorText: state.locationError,
                isBusy: state.isFetchingLocation,
                onAllow: () => context.read<PharmacySignUpCubit>().useCurrentLocation(),
                onSkip: () => AppSnackbar.show(
                  context,
                  'الموقع مطلوب لإتمام إنشاء حسابك',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
