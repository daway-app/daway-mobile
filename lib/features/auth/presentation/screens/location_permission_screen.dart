import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import '../widgets/permission_icon_header.dart';
import 'notifications_permission_screen.dart';

/// Pushed by [OtpVerificationScreen] when the backend rejects a new
/// account's OTP verify with `registration_required` (it still needs the
/// device location). Capturing it here re-submits the same OTP.
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),
                  const PermissionIconHeader(
                    icon: Icons.location_on_outlined,
                    title: 'اعثر على الأقرب إليك',
                    subtitle:
                        'فعّل موقعك لمساعدتك في العثور على أقرب الصيدليات والمنتجات المتوفرة حولك.',
                  ),
                  SizedBox(height: 24.h),
                  BlocBuilder<PatientAuthCubit, PatientAuthState>(
                    buildWhen: (previous, current) =>
                        previous.locationError != current.locationError,
                    builder: (context, state) {
                      final error = state.locationError;
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.authFieldError,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<PatientAuthCubit, PatientAuthState>(
                    buildWhen: (previous, current) =>
                        previous.isFetchingLocation != current.isFetchingLocation ||
                        previous.isVerifying != current.isVerifying,
                    builder: (context, state) {
                      final isBusy = state.isFetchingLocation || state.isVerifying;
                      return AppCustomButton(
                        text: 'السماح بالوصول للموقع',
                        backgroundColor: AppColors.primaryTeal,
                        isLoading: isBusy,
                        onPressed: isBusy
                            ? () {}
                            : () => context.read<PatientAuthCubit>().useCurrentLocation(),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => AppSnackbar.show(
                      context,
                      'الموقع مطلوب لإتمام إنشاء حسابك',
                    ),
                    child: Text(
                      'تخطي',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authFooterMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
