import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_type.dart';

class AccountTypeCubit extends Cubit<AccountType> {
  AccountTypeCubit() : super(AccountType.patient);

  void selectAccountType(AccountType type) => emit(type);
}
