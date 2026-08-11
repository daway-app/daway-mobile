import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/logout_usecase.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUseCase _logoutUseCase;

  LogoutCubit(this._logoutUseCase) : super(const LogoutState());

  Future<void> logout() async {
    emit(state.copyWith(isLoggingOut: true));
    await _logoutUseCase();
    emit(state.copyWith(isLoggingOut: false, isLoggedOut: true));
  }
}
