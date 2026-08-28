import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_seen_usecase.dart';
import '../../features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import '../../features/patient/data/datasources/patient_profile_remote_data_source.dart';
import '../../features/patient/data/repositories/cloudinary_avatar_repository_impl.dart';
import '../../features/patient/data/repositories/location_repository_impl.dart';
import '../../features/patient/data/repositories/patient_profile_repository_impl.dart';
import '../../features/patient/domain/repositories/avatar_repository.dart';
import '../../features/patient/domain/repositories/location_repository.dart';
import '../../features/patient/domain/repositories/patient_profile_repository.dart';
import '../../features/patient/domain/usecases/get_current_location_usecase.dart';
import '../../features/patient/domain/usecases/get_patient_profile_usecase.dart';
import '../../features/patient/domain/usecases/reverse_geocode_usecase.dart';
import '../../features/patient/domain/usecases/search_address_usecase.dart';
import '../../features/patient/domain/usecases/update_patient_profile_usecase.dart';
import '../../features/patient/domain/usecases/upload_avatar_usecase.dart';
import '../../features/patient/presentation/cubit/complete_profile_cubit.dart';
import '../../features/patient/presentation/cubit/location_picker_cubit.dart';
import '../../features/patient/presentation/cubit/patient_profile_cubit.dart';
import '../../features/pharmacy/data/datasources/pharmacy_dashboard_remote_data_source.dart';
import '../../features/pharmacy/data/datasources/pharmacy_inventory_remote_data_source.dart';
import '../../features/pharmacy/data/datasources/pharmacy_medicine_remote_data_source.dart';
import '../../features/pharmacy/data/datasources/pharmacy_profile_remote_data_source.dart';
import '../../features/pharmacy/data/repositories/pharmacy_dashboard_repository_impl.dart';
import '../../features/pharmacy/data/repositories/pharmacy_inventory_repository_impl.dart';
import '../../features/pharmacy/data/repositories/pharmacy_medicine_repository_impl.dart';
import '../../features/pharmacy/data/repositories/pharmacy_profile_repository_impl.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_dashboard_repository.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import '../../features/pharmacy/domain/repositories/pharmacy_profile_repository.dart';
import '../../features/pharmacy/domain/usecases/add_pharmacy_medicine_by_name_usecase.dart';
import '../../features/pharmacy/domain/usecases/add_pharmacy_medicine_usecase.dart';
import '../../features/pharmacy/domain/usecases/delete_pharmacy_medicine_usecase.dart';
import '../../features/pharmacy/domain/usecases/get_pharmacy_dashboard_stats_usecase.dart';
import '../../features/pharmacy/domain/usecases/get_pharmacy_inventory_usecase.dart';
import '../../features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import '../../features/pharmacy/domain/usecases/update_pharmacy_inventory_usecase.dart';
import '../../features/pharmacy/domain/usecases/get_pharmacy_profile_usecase.dart';
import '../../features/pharmacy/domain/usecases/search_medicine_catalog_usecase.dart';
import '../../features/pharmacy/domain/usecases/update_pharmacy_medicine_usecase.dart';
import '../../features/pharmacy/domain/usecases/update_pharmacy_profile_usecase.dart';
import '../../features/pharmacy/domain/entities/medicine.dart';
import '../../features/pharmacy/presentation/cubit/add_medicine_cubit.dart';
import '../../features/pharmacy/presentation/cubit/edit_medicine_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_dashboard_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_inventory_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_medicines_cubit.dart';
import '../../features/pharmacy/presentation/cubit/pharmacy_profile_cubit.dart';
import '../local_storage/secure_storage_service.dart';
import '../networking/dio_factory.dart';

const String _cloudinaryDioInstanceName = 'cloudinaryDio';

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

  // ---------------- Onboarding ----------------
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetOnboardingSeenUseCase(getIt()));
  getIt.registerLazySingleton(() => SetOnboardingSeenUseCase(getIt()));
  getIt.registerFactory(
    () => PatientAuthCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory(
    () => PharmacyAuthCubit(getIt(), getIt()),
  );
  getIt.registerFactory(
    () => LogoutCubit(getIt()),
  );

  // ---------------- Patient Profile ----------------
  getIt.registerLazySingleton(() => PatientProfileRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PatientProfileRepository>(
    () => PatientProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => UpdatePatientProfileUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => GetPatientProfileUseCase(getIt(), getIt()));

  // ---------------- Location ----------------
  getIt.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl());
  getIt.registerLazySingleton(() => GetCurrentLocationUseCase(getIt()));
  getIt.registerLazySingleton(() => ReverseGeocodeUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchAddressUseCase(getIt()));
  getIt.registerFactoryParam<LocationPickerCubit, LocationPickerParams, void>(
    (params, _) => LocationPickerCubit(
      getIt(),
      getIt(),
      getIt(),
      initialLatitude: params.initialLatitude,
      initialLongitude: params.initialLongitude,
      initialAddress: params.initialAddress,
    ),
  );

  // ---------------- Avatar Upload (Cloudinary, unsigned preset — see
  // CloudinaryAvatarRepositoryImpl doc comment) ----------------
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )),
    instanceName: _cloudinaryDioInstanceName,
  );
  getIt.registerLazySingleton<AvatarRepository>(
    () => CloudinaryAvatarRepositoryImpl(
      getIt(instanceName: _cloudinaryDioInstanceName),
      cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
      uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    ),
  );
  getIt.registerLazySingleton(() => UploadAvatarUseCase(getIt()));

  // ---------------- Patient Dashboard ----------------
  getIt.registerFactory(
    () => PatientProfileCubit(getIt(), getIt(), getIt()),
  );

  // ---------------- Pharmacy Profile ----------------
  getIt.registerLazySingleton(() => PharmacyProfileRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PharmacyProfileRepository>(
    () => PharmacyProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetPharmacyProfileUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => UpdatePharmacyProfileUseCase(getIt(), getIt()));
  getIt.registerFactory(
    () => PharmacyProfileCubit(getIt(), getIt(), getIt()),
  );

  // ---------------- Pharmacy Medicines ----------------
  getIt.registerLazySingleton(() => PharmacyMedicineRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PharmacyMedicineRepository>(
    () => PharmacyMedicineRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetPharmacyMedicinesUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => SearchMedicineCatalogUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => AddPharmacyMedicineUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => AddPharmacyMedicineByNameUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => DeletePharmacyMedicineUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => UpdatePharmacyMedicineUseCase(getIt(), getIt()));
  getIt.registerFactory(() => PharmacyMedicinesCubit(getIt(), getIt()));
  getIt.registerFactory(() => AddMedicineCubit(getIt(), getIt(), getIt(), getIt()));
  getIt.registerFactoryParam<EditMedicineCubit, Medicine, void>(
    (medicine, _) => EditMedicineCubit(getIt(), medicine),
  );

  // ---------------- Pharmacy Inventory ----------------
  getIt.registerLazySingleton(() => PharmacyInventoryRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PharmacyInventoryRepository>(
    () => PharmacyInventoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetPharmacyInventoryUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => UpdatePharmacyInventoryUseCase(getIt(), getIt()));
  getIt.registerFactory(() => PharmacyInventoryCubit(getIt(), getIt()));

  // ---------------- Pharmacy Dashboard ----------------
  getIt.registerLazySingleton(() => PharmacyDashboardRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PharmacyDashboardRepository>(
    () => PharmacyDashboardRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetPharmacyDashboardStatsUseCase(getIt(), getIt()));
  getIt.registerFactory(() => PharmacyDashboardCubit(getIt()));

  // ---------------- Complete Profile ----------------
  getIt.registerFactoryParam<CompleteProfileCubit, String, void>(
    (phone, _) => CompleteProfileCubit(
      getIt(),
      getIt(),
      phone: phone,
      defaultAvatarUrl: dotenv.env['CLOUDINARY_DEFAULT_AVATAR_URL'] ?? '',
    ),
  );
}
