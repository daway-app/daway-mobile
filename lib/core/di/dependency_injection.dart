import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/cubit/account_type_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerFactory<AccountTypeCubit>(() => AccountTypeCubit());
}