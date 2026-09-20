import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../cubit/patient_profile_cubit.dart';
import '../cubit/patient_profile_state.dart';

/// Greeting + cart/notification actions + the patient's saved location —
/// the top block of [PatientHomeScreen]. Only the greeting/location text
/// depends on [PatientProfileCubit], so that's the only part rebuilt while
/// the profile loads — the cart/notification buttons stay outside the
/// builder.
class HomeHeader extends StatelessWidget {
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onLocationTap;

  const HomeHeader({
    super.key,
    required this.onCartTap,
    required this.onNotificationsTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Greeting first so it lands on the physical right (a Row's
            // first child sits at its "start", which is the right edge
            // under this app's RTL 'ar' locale) — the cart/notification
            // icons sit on the left, per the design.
            Expanded(
              child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
                builder: (context, state) {
                  final name = state is PatientProfileLoaded ? state.name : '';
                  return Text.rich(
                    TextSpan(
                      style: AppTextStyles.homeGreetingRegular,
                      children: [
                        const TextSpan(text: 'أهلا بك '),
                        TextSpan(text: name, style: AppTextStyles.homeGreetingName),
                      ],
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            SizedBox(width: 16.w),
            _IconButton(assetName: 'assets/icons/notification_icon.svg', onTap: onNotificationsTap),
            SizedBox(width: 16.w),
            _IconButton(assetName: 'assets/icons/cart_icon.svg', onTap: onCartTap),
          ],
        ),
        GestureDetector(
          onTap: onLocationTap,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/location_icon.svg', width: 18.w, height: 18.w),
              SizedBox(width: 4.w),
              BlocBuilder<PatientProfileCubit, PatientProfileState>(
                builder: (context, state) {
                  final address = state is PatientProfileLoaded ? state.address : null;
                  return Text(
                    (address == null || address.isEmpty) ? 'حدد موقعك' : address,
                    style: AppTextStyles.homeLocationText,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;

  const _IconButton({required this.assetName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.iconBlueBorder),
        ),
        child: SvgPicture.asset(assetName, width: 22.w, height: 22.w),
      ),
    );
  }
}
