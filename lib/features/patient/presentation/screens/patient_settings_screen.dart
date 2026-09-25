import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_toggle_switch.dart';
import '../../../../core/widgets/logout_confirmation_sheet.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/screens/privacy_policy_screen.dart';
import '../../../auth/presentation/screens/terms_screen.dart';
import '../../domain/entities/account_settings.dart';
import '../../domain/entities/device_setting.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';
import '../widgets/account_row_card.dart';
import '../widgets/language_bottom_sheet.dart';
import '../widgets/patient_sub_screen_header.dart';
import '../widgets/settings_brand_footer.dart';
import '../widgets/settings_section_label.dart';

/// The account-settings screen (opened from the account hub's "الإعدادات"
/// row): preferences, privacy links, logout, and the app version.
///
/// Expects an [AccountSettingsCubit] and a [LogoutCubit] to already be
/// provided above it; [route] does that for every place that opens it.
///
/// This is the only place a patient can log out from.
///
/// The two switches show the device's real permission state. An app cannot
/// change a permission itself, so tapping one sends the user to the system
/// settings, and the state is re-read when they come back. There is no
/// English translation yet, so picking English shows the "قريباً" cue.
class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  /// The route to this screen, for the account hub and the side menu alike.
  /// It is pushed above the route that provides the [LogoutCubit] (the tab
  /// shell), so the caller hands that cubit down.
  static Route<void> route({required LogoutCubit logoutCubit}) {
    return MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AccountSettingsCubit>()),
          BlocProvider.value(value: logoutCubit),
        ],
        child: const PatientSettingsScreen(),
      ),
    );
  }

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen>
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

  Future<void> _openDeviceSettings(DeviceSetting setting) async {
    final error = await context.read<AccountSettingsCubit>().openSettings(setting);
    if (!mounted || error == null) return;
    AppSnackbar.show(context, error);
  }

  Future<void> _pickLanguage() async {
    final picked = await LanguageBottomSheet.show(context, selected: _currentLanguage);
    if (!mounted || picked == null || picked == _currentLanguage) return;
    AppSnackbar.show(context, 'قريباً');
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
                  title: 'معلومات الحساب',
                  description: 'إدارة معلوماتك الشخصية وتفاصيل حسابك',
                ),
              ),
            ),
            // Fills what is left of the screen so the brand footer sits at
            // the bottom on tall screens, and scrolls with the rest on short ones.
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

  /// The switches (and the version) are the only parts that need the device
  /// state; every other row is always shown, so a failed read can never take
  /// the logout, privacy or language rows away with it.
  Widget _permissionSwitch(AccountSettingsState state, bool Function(AccountSettings) isEnabled) {
    return switch (state) {
      // No switch yet while the device is being asked: an OFF that slides ON a
      // moment later would look like a glitch.
      AccountSettingsLoading() => SizedBox(width: 50.w, height: 28.h),
      AccountSettingsLoaded(:final settings) => AppToggleSwitch(value: isEnabled(settings)),
      // Unreadable: shown OFF, with a retry under the cards. The row itself
      // still opens the system settings, which needs no state.
      AccountSettingsLoadFailure() => const AppToggleSwitch(value: false),
    };
  }

  Widget _buildSettings(AccountSettingsState state) {
    final settings = state is AccountSettingsLoaded ? state.settings : null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          const SettingsSectionLabel('التفضيلات'),
          SizedBox(height: 8.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/globe_icon.svg'),
            label: 'اللغة',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_currentLanguage.nativeName, style: AppTextStyles.settingsMutedText),
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
            trailing: _permissionSwitch(state, (settings) => settings.notificationsEnabled),
            onTap: () => _openDeviceSettings(DeviceSetting.notifications),
          ),
          SizedBox(height: 16.h),
          AccountRowCard(
            leading: const AccountRowIcon('assets/icons/map_pin_icon.svg'),
            label: 'الموقع',
            trailing: _permissionSwitch(state, (settings) => settings.locationEnabled),
            onTap: () => _openDeviceSettings(DeviceSetting.location),
          ),
          if (state is AccountSettingsLoadFailure) ...[
            SizedBox(height: 12.h),
            _InlineRetry(
              message: state.message,
              onRetry: () => context.read<AccountSettingsCubit>().load(),
            ),
          ],
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
            trailing: const AccountRowIcon('assets/icons/log_out_icon.svg', color: AppColors.logoutRed),
            height: 58,
            radius: 12,
            onTap: _confirmLogout,
          ),
          SizedBox(height: 40.h),
          const Spacer(),
          SettingsBrandFooter(version: settings?.appVersion),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}

/// A one-line "could not read the state" message with a retry link, shown
/// under the preferences when the device state could not be read.
class _InlineRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(message, textAlign: TextAlign.right, style: AppTextStyles.settingsMutedText),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onRetry,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'إعادة المحاولة',
              style: AppTextStyles.settingsMutedText.copyWith(
                color: AppColors.mainTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
