import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/location_permission_view.dart';
import 'notifications_permission_screen.dart';

/// Pushed by [OtpVerificationScreen] when the backend rejects a new
/// account's OTP verify with `registration_required` (it still needs the
/// device location). Capturing it here re-submits the same OTP.
///
/// Back navigation is left enabled (no `PopScope`) so a user whose location
/// permission is permanently denied still has a way out, back to the
/// previous step, instead of being stuck on this screen forever.
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  void _continue(BuildContext context) {
    final cubit = context.read<PatientAuthCubit>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const NotificationsPermissionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PatientAuthCubit, PatientAuthState>(
          listenWhen: (previous, current) =>
              (current.destination != null && previous.destination != current.destination) ||
              (current.errorMessage != null && previous.errorMessage != current.errorMessage),
          listener: (context, state) {
            if (state.destination != null) {
              _continue(context);
            } else if (state.errorMessage != null) {
              AppSnackbar.show(context, state.errorMessage!);
            }
          },
          child: BlocBuilder<PatientAuthCubit, PatientAuthState>(
            buildWhen: (previous, current) =>
                previous.isFetchingLocation != current.isFetchingLocation ||
                previous.isVerifying != current.isVerifying ||
                previous.locationError != current.locationError,
            builder: (context, state) {
              return LocationPermissionView(
                subtitle:
                    'فعّل موقعك لمساعدتك في العثور على أقرب الصيدليات والمنتجات المتوفرة حولك.',
                buttonColor: AppColors.primaryTeal,
                errorText: state.locationError,
                isBusy: state.isFetchingLocation || state.isVerifying,
                onAllow: () => context.read<PatientAuthCubit>().useCurrentLocation(),
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
