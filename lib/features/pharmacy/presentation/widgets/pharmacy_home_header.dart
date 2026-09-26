import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/header_icon_button.dart';
import '../cubit/pharmacy_profile_cubit.dart';
import '../cubit/pharmacy_profile_state.dart';

/// Greeting, the pharmacy's address and the notifications button — the top
/// block of [PharmacyHomeScreen]. Only the name and the address depend on
/// [PharmacyProfileCubit] (each through its own selector, so an edit of one
/// does not rebuild the other); the notifications button stays outside.
///
/// Both read the *saved* profile, not the edits in progress on the profile
/// tab, which share the same cubit.
class PharmacyHomeHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;

  const PharmacyHomeHeader({super.key, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First, so it lands on the physical right under the app's RTL
        // locale; the notifications button sits on the left, per the design.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The design sets the greeting 6px in from the right edge; the
              // address row below is flush with it.
              Padding(
                padding: EdgeInsetsDirectional.only(start: 6.w),
                child: BlocSelector<PharmacyProfileCubit, PharmacyProfileState, String>(
                  selector: (state) => state is PharmacyProfileLoaded ? state.profile.name : '',
                  builder: (context, name) {
                    return Text.rich(
                      TextSpan(
                        style: AppTextStyles.homeGreetingRegular,
                        children: [
                          const TextSpan(text: 'أهلا بك '),
                          TextSpan(text: name, style: AppTextStyles.pharmacyGreetingName),
                        ],
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
              // Keeps its height while the address is still loading (or the
              // pharmacy has none yet), so what is below does not jump.
              SizedBox(
                height: 24.h,
                child: BlocSelector<PharmacyProfileCubit, PharmacyProfileState, String?>(
                  selector: (state) => state is PharmacyProfileLoaded ? state.profile.address : null,
                  builder: (context, address) {
                    if (address == null || address.isEmpty) return const SizedBox.shrink();
                    return Row(
                      children: [
                        SvgPicture.asset('assets/icons/location_icon.svg', width: 24.w, height: 24.w),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.homeLocationText,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        // 2px below the greeting's top, as the design has it.
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: HeaderIconButton(
            assetName: 'assets/icons/notification_icon.svg',
            iconSize: 26,
            onTap: onNotificationsTap,
          ),
        ),
      ],
    );
  }
}
