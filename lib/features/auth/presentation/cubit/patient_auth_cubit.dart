import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/validators.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/usecases/save_session_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'patient_auth_state.dart';

/// Drives the single merged patient phone-entry + OTP screen. There is no
/// dedicated "register" endpoint in the backend — verifying the OTP either
/// logs the patient in or creates their account, and the response tells us
/// which one happened via [PatientAuthResult.isNewAccount].
class PatientAuthCubit extends Cubit<PatientAuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SaveSessionUseCase _saveSessionUseCase;

  PatientAuthCubit(
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._saveSessionUseCase,
  ) : super(const PatientAuthState());

  void phoneChanged(String phone) {
    emit(state.copyWith(phone: phone, clearError: true));
  }

  void termsToggled(bool value) {
    emit(state.copyWith(agreedToTerms: value, clearError: true));
  }

  Future<void> sendOtp() async {
    if (!state.agreedToTerms) {
      emit(state.copyWith(
        errorMessage: 'يجب الموافقة على شروط الخدمة وسياسة الخصوصية للمتابعة',
      ));
      return;
    }
    if (!Validators.isValidLocalPhone(state.phone)) {
      emit(state.copyWith(errorMessage: 'يرجى إدخال رقم جوال صحيح مكوّن من 10 أرقام'));
      return;
    }

    emit(state.copyWith(isSendingOtp: true, clearError: true));
    final result = await _sendOtpUseCase(phone: state.phone);

    switch (result) {
      case Success(:final data):
        if (kDebugMode && data != null) {
          debugPrint('OTP for ${state.phone}: $data');
        }
        emit(state.copyWith(isSendingOtp: false, otpSent: true));
      case ApiError(:final failure):
        emit(state.copyWith(isSendingOtp: false, errorMessage: failure.message));
    }
  }

  void backToPhoneStep() {
    emit(state.copyWith(otpSent: false, clearError: true));
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.length != 6) {
      emit(state.copyWith(errorMessage: 'يرجى إدخال رمز التحقق المكوّن من 6 أرقام'));
      return;
    }

    emit(state.copyWith(isVerifying: true, clearError: true));
    final result = await _verifyOtpUseCase(phone: state.phone, otp: otp);

    switch (result) {
      case Success(:final data):
        final token = data.token;
        if (token != null) {
          await _saveSessionUseCase(accountType: AccountType.patient, token: token);
        }
        emit(state.copyWith(
          isVerifying: false,
          destination: data.isNewAccount ? AuthDestination.profile : AuthDestination.home,
        ));
      case ApiError(:final failure):
        emit(state.copyWith(isVerifying: false, errorMessage: failure.message));
    }
  }
}
