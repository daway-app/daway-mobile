import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/validators.dart';
import '../../../patient/domain/usecases/get_current_location_usecase.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/usecases/save_session_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'patient_auth_state.dart';

/// Drives both the plain phone-only login screen and the sign-up screen
/// (name + birth date collected up front). There is no separate "register"
/// endpoint — verifying the OTP either logs the patient in or creates their
/// account; for a brand-new phone the backend also requires the full
/// registration payload (name/birth_date/latitude/longitude) on that same
/// call, rejecting an incomplete one with `registration_required` while
/// keeping the OTP valid for a retry.
class PatientAuthCubit extends Cubit<PatientAuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SaveSessionUseCase _saveSessionUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  String _lastOtp = '';

  PatientAuthCubit(
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._saveSessionUseCase,
    this._getCurrentLocationUseCase,
  ) : super(const PatientAuthState());

  void phoneChanged(String phone) {
    emit(state.copyWith(phone: phone, clearError: true));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name, clearError: true));
  }

  void birthDateChanged(String birthDate) {
    emit(state.copyWith(birthDate: birthDate, clearError: true));
  }

  Future<void> sendOtp() async {
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

    _lastOtp = otp;
    emit(state.copyWith(isVerifying: true, clearError: true));
    await _submitVerify();
  }

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(isFetchingLocation: true, clearLocationError: true));

    final result = await _getCurrentLocationUseCase();
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(
          isFetchingLocation: false,
          needsLocation: false,
          latitude: data.latitude,
          longitude: data.longitude,
          isVerifying: true,
        ));
        await _submitVerify();
      case ApiError(:final failure):
        emit(state.copyWith(isFetchingLocation: false, locationError: failure.message));
    }
  }

  Future<void> _submitVerify() async {
    final result = await _verifyOtpUseCase(
      phone: state.phone,
      otp: _lastOtp,
      name: state.name,
      birthDate: state.birthDate,
      latitude: state.latitude,
      longitude: state.longitude,
    );

    switch (result) {
      case Success(:final data):
        final token = data.token;
        if (token != null) {
          await _saveSessionUseCase(accountType: AccountType.patient, token: token);
        }
        emit(state.copyWith(
          isVerifying: false,
          destination: state.isSignUp ? AuthDestination.notifications : AuthDestination.home,
        ));
      case ApiError(:final failure):
        if (failure is ApiFailure && failure.registrationRequired) {
          if (state.isSignUp) {
            // Re-request location even if we already have a (possibly
            // stale) one on file — retrying with a fresh fix is the only
            // actionable next step the user has for this rejection.
            emit(state.copyWith(isVerifying: false, needsLocation: true));
          } else {
            // Reached from the plain phone-only login screen: the backend
            // has no account for this phone and needs the full sign-up
            // payload (name/birth date) we never collected here.
            emit(state.copyWith(
              isVerifying: false,
              errorMessage: 'لا يوجد حساب بهذا الرقم، يرجى إنشاء حساب جديد',
            ));
          }
        } else {
          emit(state.copyWith(isVerifying: false, errorMessage: failure.message));
        }
    }
  }
}
