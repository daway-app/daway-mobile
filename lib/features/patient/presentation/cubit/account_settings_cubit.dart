import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/device_setting.dart';
import '../../domain/usecases/get_account_settings_usecase.dart';
import '../../domain/usecases/open_device_settings_usecase.dart';
import 'account_settings_state.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final GetAccountSettingsUseCase _getAccountSettingsUseCase;
  final OpenDeviceSettingsUseCase _openDeviceSettingsUseCase;

  /// Bumped per read so a slow, older read can't overwrite a newer one (e.g.
  /// a resume-triggered [refresh] landing while the first [load] is in flight).
  int _latestRead = 0;

  AccountSettingsCubit(this._getAccountSettingsUseCase, this._openDeviceSettingsUseCase)
      : super(const AccountSettingsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const AccountSettingsLoading());
    final read = ++_latestRead;
    final result = await _getAccountSettingsUseCase();
    if (isClosed || read != _latestRead) return;
    switch (result) {
      case Success(:final data):
        emit(AccountSettingsLoaded(data));
      case ApiError(:final failure):
        emit(AccountSettingsLoadFailure(failure.message));
    }
  }

  /// Re-reads the device state without a loading flash — used when the user
  /// comes back from system settings, where they may have changed it. A
  /// failed re-read keeps the values already on screen.
  Future<void> refresh() async {
    if (state is! AccountSettingsLoaded) return;
    final read = ++_latestRead;
    final result = await _getAccountSettingsUseCase();
    if (isClosed || read != _latestRead) return;
    if (result case Success(:final data)) emit(AccountSettingsLoaded(data));
  }

  /// Sends the user to the system screen for [setting]. Returns null on
  /// success, or a user-facing error message on failure.
  Future<String?> openSettings(DeviceSetting setting) async {
    final result = await _openDeviceSettingsUseCase(setting);
    return switch (result) {
      Success() => null,
      ApiError(:final failure) => failure.message,
    };
  }
}
