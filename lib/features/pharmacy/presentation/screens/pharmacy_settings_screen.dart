import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/open_location_picker.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/account_row_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../core/widgets/incomplete_profile_banner.dart';
import '../../../../core/widgets/logout_confirmation_sheet.dart';
import '../../../../core/widgets/settings_brand_footer.dart';
import '../../../../core/widgets/settings_section_label.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/screens/privacy_policy_screen.dart';
import '../../../auth/presentation/screens/terms_screen.dart';
import '../../../patient/domain/entities/device_setting.dart';
import '../../../patient/presentation/cubit/account_settings_cubit.dart';
import '../../../patient/presentation/cubit/account_settings_state.dart';
import '../../../patient/presentation/widgets/language_bottom_sheet.dart';
import '../../../patient/presentation/widgets/patient_sub_screen_header.dart';
import '../cubit/pharmacy_profile_cubit.dart';
import '../cubit/pharmacy_profile_state.dart';
import 'pharmacy_account_info_screen.dart';

/// The pharmacy's الإعدادات tab: the account-info page, language,
/// notifications, the location, the privacy links, logout and the app version.
///
/// Expects a [PharmacyProfileCubit] and a [LogoutCubit] above it (the shell
/// provides both) and makes its own [AccountSettingsCubit].
///
/// The notifications switch shows the device's real permission, as the
/// patient's settings do: an app cannot change a permission itself, so a tap
/// opens the system settings and the state is re-read when the user returns.
/// There is no English translation yet, so picking English shows "قريباً".
class PharmacySettingsScreen extends StatelessWidget {
  const PharmacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AccountSettingsCubit>(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody();

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody>
    with WidgetsBindingObserver {
  /// The app only ships in Arabic today, so this is fixed.
  static const _currentLanguage = AppLanguage.arabic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from system settings, where the user may have changed a permission.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AccountSettingsCubit>().refresh();
    }
  }

  Future<void> _openNotificationSettings() async {
    final error = await context.read<AccountSettingsCubit>().openSettings(
      DeviceSetting.notifications,
    );
    if (!mounted || error == null) return;
    AppSnackbar.show(context, error);
  }

  Future<void> _pickLanguage() async {
    final picked = await LanguageBottomSheet.show(
      context,
      selected: _currentLanguage,
    );
    if (!mounted || picked == null || picked == _currentLanguage) return;
    AppSnackbar.show(context, 'قريباً');
  }

  void _openAccountInfo() {
    final profileCubit = context.read<PharmacyProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: const PharmacyAccountInfoScreen(),
        ),
      ),
    );
  }

  /// Opens the map (with its search bar) at the pharmacy's current location
  /// and saves whatever the pharmacy confirms.
  Future<void> _updateLocation() async {
    final cubit = context.read<PharmacyProfileCubit>();
    final current = cubit.state;
    if (current is! PharmacyProfileLoaded) {
      AppSnackbar.show(context, 'تعذّر تحميل بيانات الصيدلية، حاول مرة أخرى');
      return;
    }
    final picked = await openLocationPicker(
      context,
      latitude: current.latitude,
      longitude: current.longitude,
      address: current.address,
    );
    if (picked == null || !mounted) return;
    cubit.locationSelected(picked);
    await cubit.save();
    if (!mounted) return;
    final after = cubit.state;
    if (after is! PharmacyProfileLoaded) return;
    if (after.saveError != null) {
      AppSnackbar.show(context, after.saveError!);
      // A failed save must not leave the unsaved location sitting in the
      // shared profile for the account-info screen to pick up.
      cubit.discardEdits();
    } else {
      AppSnackbar.show(context, 'تم تحديث الموقع');
    }
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _confirmLogout() {
    LogoutConfirmationSheet.show(
      context,
      onConfirm: () => context.read<LogoutCubit>().logout(),
    );
  }

  Widget _notificationsSwitch(AccountSettingsState state) {
    return switch (state) {
      // No switch yet while the device is being asked: an OFF that slides ON a
      // moment later would look like a glitch.
      AccountSettingsLoading() => SizedBox(width: 50.w, height: 28.h),
      AccountSettingsLoaded(:final settings) => AppToggleSwitch(
        value: settings.notificationsEnabled,
      ),
      AccountSettingsLoadFailure() => const AppToggleSwitch(value: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const PatientSubScreenHeader(
                  title: 'الإعدادات',
                  description: 'إدارة معلوماتك الشخصية وتفاصيل حسابك',
                  showBackButton: false,
                ),
              ),
            ),
            // Fills what is left of the screen so the brand footer sits at the
            // bottom on tall screens, and scrolls with the rest on short ones.
            SliverFillRemaining(
              hasScrollBody: false,
              child: BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
                builder: (context, state) => _buildSettings(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(AccountSettingsState state) {
    final version = state is AccountSettingsLoaded
        ? state.settings.appVersion
        : null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          BlocSelector<PharmacyProfileCubit, PharmacyProfileState, bool>(
            selector: (profile) =>
                profile is PharmacyProfileLoaded && profile.isIncomplete,
            builder: (context, isIncomplete) => isIncomplete
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const IncompleteProfileBanner(),
                  )
                : const SizedBox.shrink(),
          ),
          const SettingsSectionLabel('التفضيلات'),
          SizedBox(height: 8.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/user_icon.svg'),
            label: 'معلومات الحساب',
            trailing: const AccountRowChevron(),
            onTap: _openAccountInfo,
          ),
          SizedBox(height: 16.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/globe_icon.svg'),
            label: 'اللغة',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentLanguage.nativeName,
                  style: AppTextStyles.settingsMutedText,
                ),
                SizedBox(width: 8.w),
                const AccountRowChevron(),
              ],
            ),
            onTap: _pickLanguage,
          ),
          SizedBox(height: 16.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/bell_icon.svg'),
            label: 'الإشعارات',
            trailing: _notificationsSwitch(state),
            onTap: _openNotificationSettings,
          ),
          SizedBox(height: 16.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/map_pin_icon.svg'),
            label: 'تحديث الموقع',
            onTap: _updateLocation,
          ),
          SizedBox(height: 32.h),
          const SettingsSectionLabel('الخصوصية والأمان'),
          SizedBox(height: 8.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/shield_icon.svg'),
            label: 'سياسة الخصوصية',
            trailing: const AccountRowChevron(),
            onTap: () => _push(const PrivacyPolicyScreen()),
          ),
          SizedBox(height: 16.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/file_text_icon.svg'),
            label: 'الشروط والأحكام',
            trailing: const AccountRowChevron(),
            onTap: () => _push(const TermsScreen()),
          ),
          SizedBox(height: 24.h),
          const SettingsSectionLabel('الحساب'),
          SizedBox(height: 8.h),
          AccountRowCard(
            label: 'تسجيل الخروج',
            labelColor: AppColors.logoutRed,
            trailing: const AccountRowIcon(
              'assets/icons/log_out_icon.svg',
              color: AppColors.logoutRed,
            ),
            height: 58,
            radius: 12,
            onTap: _confirmLogout,
          ),
          SizedBox(height: 40.h),
          const Spacer(),
          SettingsBrandFooter(version: version),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
