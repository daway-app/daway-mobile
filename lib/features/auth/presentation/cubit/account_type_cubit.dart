import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/domain/usecases/get_onboarding_seen_usecase.dart';
import '../../../onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import '../../domain/entities/account_type.dart';

class AccountTypeCubit extends Cubit<AccountType> {
  final GetOnboardingSeenUseCase _getOnboardingSeenUseCase;
  final SetOnboardingSeenUseCase _setOnboardingSeenUseCase;

  AccountTypeCubit(this._getOnboardingSeenUseCase, this._setOnboardingSeenUseCase)
      : super(AccountType.patient);

  void selectAccountType(AccountType type) => emit(type);

  Future<bool> hasSeenOnboarding(AccountType type) => _getOnboardingSeenUseCase(type);

  Future<void> markOnboardingSeen(AccountType type) => _setOnboardingSeenUseCase(type);
}
