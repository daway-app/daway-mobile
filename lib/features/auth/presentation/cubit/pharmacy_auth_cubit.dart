import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/usecases/pharmacy_login_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';
import 'pharmacy_auth_state.dart';

class PharmacyAuthCubit extends Cubit<PharmacyAuthState> {
  final PharmacyLoginUseCase _loginUseCase;
  final SaveSessionUseCase _saveSessionUseCase;

  PharmacyAuthCubit(this._loginUseCase, this._saveSessionUseCase)
      : super(const PharmacyAuthState());

  Future<void> login({required String pharmacyId, required String password}) async {
    emit(state.copyWith(isLoggingIn: true, clearError: true));
    final result = await _loginUseCase(pharmacyId: pharmacyId, password: password);

    switch (result) {
      case Success(:final data):
        await _saveSessionUseCase(accountType: AccountType.pharmacy, token: data.token);
        emit(state.copyWith(isLoggingIn: false, token: data.token));
      case ApiError(:final failure):
        emit(state.copyWith(isLoggingIn: false, errorMessage: failure.message));
    }
  }
}
