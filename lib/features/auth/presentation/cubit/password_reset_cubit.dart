import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_password_reset_code_usecase.dart';
import '../../domain/usecases/verify_password_reset_code_usecase.dart';
import 'password_reset_state.dart';

/// Drives the four screens of resetting a pharmacy's forgotten password (see
/// [PasswordResetStep]): the phone number, the code sent to it, the new
/// password, and the confirmation. One cubit serves all of them, so what an
/// earlier screen learned (the phone, the proof the code was accepted) is there
/// for the next.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  final SendPasswordResetCodeUseCase _sendCodeUseCase;
  final VerifyPasswordResetCodeUseCase _verifyCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  // How many times the user has gone back a screen. A request answers to the
  // screen it was sent from: if they left it while it was on its way, the answer
  // is dropped rather than moving the flow on from a step they are no longer on.
  int _backs = 0;

  PasswordResetCubit(
    this._sendCodeUseCase,
    this._verifyCodeUseCase,
    this._resetPasswordUseCase,
  ) : super(const PasswordResetState());

  /// Sends the code to [phone]; on success the flow moves on to the code step.
  Future<void> sendCode(String phone) async {
    emit(state.copyWith(isBusy: true, clearMessages: true));
    final backs = _backs;

    final result = await _sendCodeUseCase(phone: phone);
    if (_isStale(backs)) return;

    switch (result) {
      case Success():
        emit(state.copyWith(isBusy: false, phone: phone, step: PasswordResetStep.code));
      case ApiError(:final failure):
        emit(_failed(failure));
    }
  }

  /// Asks for a new code for the number already given. True when it was sent,
  /// so the caller can restart its countdown.
  Future<bool> resendCode() async {
    emit(state.copyWith(isBusy: true, clearMessages: true));
    final backs = _backs;

    final result = await _sendCodeUseCase(phone: state.phone);
    if (_isStale(backs)) return false;

    switch (result) {
      case Success():
        emit(state.copyWith(isBusy: false));
        return true;
      case ApiError(:final failure):
        emit(_failed(failure));
        return false;
    }
  }

  /// Checks the [code] typed in; on success the flow moves on to the new
  /// password step.
  Future<void> verifyCode(String code) async {
    emit(state.copyWith(isBusy: true, clearMessages: true));
    final backs = _backs;

    final result = await _verifyCodeUseCase(phone: state.phone, code: code);
    if (_isStale(backs)) return;

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(isBusy: false, resetToken: data, step: PasswordResetStep.newPassword));
      case ApiError(:final failure):
        emit(_failed(failure));
    }
  }

  /// Sets the new password; on success the flow is done.
  Future<void> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(isBusy: true, clearMessages: true));
    final backs = _backs;

    final result = await _resetPasswordUseCase(
      phone: state.phone,
      resetToken: state.resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    if (_isStale(backs)) return;

    switch (result) {
      case Success():
        emit(state.copyWith(isBusy: false, step: PasswordResetStep.done));
      case ApiError(:final failure):
        emit(_failed(failure));
    }
  }

  /// The user went back a screen: the flow returns to the step before it. What
  /// the step it leaves gave (the accepted code) is forgotten, since going
  /// forward again means doing it again, and so is a request still on its way
  /// from it.
  void back() {
    final previous = switch (state.step) {
      PasswordResetStep.newPassword => PasswordResetStep.code,
      PasswordResetStep.code => PasswordResetStep.phone,
      PasswordResetStep.phone || PasswordResetStep.done => state.step,
    };
    if (previous == state.step) return;

    _backs++;
    emit(PasswordResetState(step: previous, phone: state.phone));
  }

  /// Whether the answer to a request sent when the user had gone back [backs]
  /// times is no longer wanted: the cubit is closed, or they have gone back
  /// since.
  bool _isStale(int backs) => isClosed || backs != _backs;

  PasswordResetState _failed(Failure failure) {
    // A step the backend cannot do yet is not an error to show by a field.
    return failure is ComingSoonFailure
        ? state.copyWith(isBusy: false, notice: failure.message)
        : state.copyWith(isBusy: false, errorMessage: failure.message);
  }
}
