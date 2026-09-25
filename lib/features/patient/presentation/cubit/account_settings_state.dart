import '../../domain/entities/account_settings.dart';

sealed class AccountSettingsState {
  const AccountSettingsState();
}

class AccountSettingsLoading extends AccountSettingsState {
  const AccountSettingsLoading();
}

class AccountSettingsLoadFailure extends AccountSettingsState {
  final String message;

  const AccountSettingsLoadFailure(this.message);
}

class AccountSettingsLoaded extends AccountSettingsState {
  final AccountSettings settings;

  const AccountSettingsLoaded(this.settings);
}
