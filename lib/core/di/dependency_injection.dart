import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/session_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../../features/auth/domain/usecases/get_session_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/save_session_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/pharmacy_login_usecase.dart';
import '../../features/auth/presentation/cubit/account_type_cubit.dart';
import '../../features/auth/presentation/cubit/logout_cubit.dart';
import '../../features/auth/presentation/cubit/patient_auth_cubit.dart';
import '../../features/auth/presentation/cubit/pharmacy_auth_cubit.dart';
import '../local_storage/secure_storage_service.dart';
import '../networking/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerFactory<AccountTypeCubit>(() => AccountTypeCubit());

  // ---------------- Networking ----------------
  getIt.registerLazySingleton(() => DioFactory.getDio());

  // ---------------- Local Storage ----------------
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => SecureStorageService(getIt()));

  // ---------------- Auth ----------------
  getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => PharmacyLoginUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt(), getIt()));
  getIt.registerFactory(
    () => PatientAuthCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory(
    () => PharmacyAuthCubit(getIt(), getIt()),
  );
  getIt.registerFactory(
    () => LogoutCubit(getIt()),
  );
}
