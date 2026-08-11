import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/cubit/account_type_cubit.dart';
import '../../features/auth/presentation/cubit/patient_auth_cubit.dart';
import '../networking/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerFactory<AccountTypeCubit>(() => AccountTypeCubit());

  // ---------------- Networking ----------------
  getIt.registerLazySingleton(() => DioFactory.getDio());

  // ---------------- Auth ----------------
  getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerFactory(
    () => PatientAuthCubit(getIt(), getIt()),
  );
}
