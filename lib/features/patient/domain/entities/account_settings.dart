/// What the account-settings screen shows about this device and app: whether
/// the OS currently lets the app notify / locate the user, and the installed
/// app version.
///
/// The backend's `notifications_enabled` profile flag is deliberately not
/// used: `POST /profile/patient` accepts but ignores it (only registration
/// stores it), so the device permission is the state that actually decides
/// whether the user gets notified.
class AccountSettings {
  final bool notificationsEnabled;
  final bool locationEnabled;

  /// Null when the version couldn't be read — the label is decorative, so a
  /// missing one hides it instead of failing the whole screen.
  final String? appVersion;

  const AccountSettings({
    required this.notificationsEnabled,
    required this.locationEnabled,
    this.appVersion,
  });
}
