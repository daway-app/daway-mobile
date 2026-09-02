import 'dart:async';
import 'dart:io';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/add_pharmacy_medicine_by_name_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/add_pharmacy_medicine_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/search_medicine_catalog_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/add_medicine_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/add_medicine_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalogItem = MedicineCatalogItem(
  id: 5,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  type: 'medicine',
);
const _mohCatalogItem = MedicineCatalogItem(
  id: 21,
  name: 'THE HOPPA. BETTER GLOW VIT C SERUM',
  activeIngredient: 'Orientco Limited/Turkey',
  type: 'moh',
);

class _FakePharmacyMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<MedicineCatalogItem>> searchResult = const Success([_catalogItem]);
  ApiResult<void> addResult = const Success(null);
  ApiResult<void> addByNameResult = const Success(null);
  int? lastMedicineId;
  int? lastMohMedicineId;
  double? lastPrice;
  int? lastQuantity;
  bool? lastIsAvailable;
  String? lastImageUrl;
  String? lastTradeName;
  String? lastTradeNameAr;
  String? lastActiveIngredient;

  /// When set, searchCatalog() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-search to exercise races.
  Completer<void>? searchGate;

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async {
    if (searchGate != null) await searchGate!.future;
    return searchResult;
  }

  @override
  Future<ApiResult<void>> addMedicine({
    required String token,
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    lastMedicineId = medicineId;
    lastMohMedicineId = mohMedicineId;
    lastPrice = price;
    lastQuantity = quantity;
    lastIsAvailable = isAvailable;
    lastImageUrl = imageUrl;
    return addResult;
  }

  @override
  Future<ApiResult<void>> addMedicineByName({
    required String token,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    lastTradeName = tradeName;
    lastTradeNameAr = tradeNameAr;
    lastActiveIngredient = activeIngredient;
    lastPrice = price;
    lastQuantity = quantity;
    lastIsAvailable = isAvailable;
    lastImageUrl = imageUrl;
    return addByNameResult;
  }

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

class _FakeAvatarRepository implements AvatarRepository {
  ApiResult<String> result = const Success('https://res.cloudinary.com/demo/image/upload/a.jpg');

  /// When set, uploadAvatar() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-upload to exercise races.
  Completer<void>? uploadGate;

  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async {
    if (uploadGate != null) await uploadGate!.future;
    return result;
  }
}

void main() {
  late _FakePharmacyMedicineRepository repository;
  late _FakeAvatarRepository imageRepository;
  late AddMedicineCubit cubit;

  setUp(() {
    repository = _FakePharmacyMedicineRepository();
    imageRepository = _FakeAvatarRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = AddMedicineCubit(
      SearchMedicineCatalogUseCase(repository, sessionRepository),
      AddPharmacyMedicineUseCase(repository, sessionRepository),
      AddPharmacyMedicineByNameUseCase(repository, sessionRepository),
      UploadAvatarUseCase(imageRepository),
    );
  });

  tearDown(() => cubit.close());

  test('starts empty and not submittable', () {
    final formData = cubit.state.formData;
    expect(formData.selectedMedicine, isNull);
    expect(formData.canSubmit, isFalse);
  });

  test('typing a name debounces a catalog search', () async {
    cubit.nameQueryChanged('pan');

    await Future.delayed(const Duration(milliseconds: 400));

    expect(cubit.state.formData.suggestions, [_catalogItem]);
  });

  test('a single character does not trigger a search', () async {
    cubit.nameQueryChanged('p');

    await Future.delayed(const Duration(milliseconds: 400));

    expect(cubit.state.formData.suggestions, isEmpty);
  });

  test('clearing the name query does not trigger a search', () async {
    cubit.nameQueryChanged('');

    await Future.delayed(const Duration(milliseconds: 400));

    expect(cubit.state.formData.suggestions, isEmpty);
    expect(cubit.state.formData.isSearching, isFalse);
  });

  test('clearing the query while a search is in flight discards its stale result', () async {
    final gate = Completer<void>();
    repository.searchGate = gate;

    cubit.nameQueryChanged('pan');
    await Future.delayed(const Duration(milliseconds: 400)); // let the debounce fire

    cubit.nameQueryChanged(''); // clear before the in-flight search resolves
    gate.complete();
    await Future.delayed(Duration.zero);

    final formData = cubit.state.formData;
    expect(formData.suggestions, isEmpty);
    expect(formData.isSearching, isFalse);
    expect(formData.nameQuery, '');
  });

  test('selecting a medicine while a search is in flight discards its stale result', () async {
    final gate = Completer<void>();
    repository.searchGate = gate;

    cubit.nameQueryChanged('pan');
    await Future.delayed(const Duration(milliseconds: 400)); // let the debounce fire

    cubit.medicineSelected(_catalogItem);
    gate.complete();
    await Future.delayed(Duration.zero);

    final formData = cubit.state.formData;
    expect(formData.selectedMedicine, _catalogItem);
    expect(formData.suggestions, isEmpty);
  });

  test('a failed search surfaces the failure message instead of looking like no results', () async {
    repository.searchResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    cubit.nameQueryChanged('pan');
    await Future.delayed(const Duration(milliseconds: 400));

    final formData = cubit.state.formData;
    expect(formData.suggestions, isEmpty);
    expect(formData.searchError, 'تعذر الاتصال بالخادم');
  });

  test('a new query clears a previous search error', () async {
    repository.searchResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    cubit.nameQueryChanged('pan');
    await Future.delayed(const Duration(milliseconds: 400));
    expect(cubit.state.formData.searchError, isNotNull);

    repository.searchResult = const Success([_catalogItem]);
    cubit.nameQueryChanged('ama');
    await Future.delayed(const Duration(milliseconds: 400));

    expect(cubit.state.formData.searchError, isNull);
  });

  test('medicineSelected fills the form and clears suggestions', () async {
    cubit.nameQueryChanged('pan');
    await Future.delayed(const Duration(milliseconds: 400));

    cubit.medicineSelected(_catalogItem);

    final formData = cubit.state.formData;
    expect(formData.selectedMedicine, _catalogItem);
    expect(formData.nameQuery, 'Panadol');
    expect(formData.suggestions, isEmpty);
  });

  test('activeIngredient auto-fills on selection but stays editable afterwards', () async {
    cubit.medicineSelected(_catalogItem);
    expect(cubit.state.formData.activeIngredient, 'Paracetamol 500mg');

    cubit.activeIngredientChanged('Something else entirely');
    expect(cubit.state.formData.activeIngredient, 'Something else entirely');
  });

  test('activeIngredient resets when the name search restarts', () {
    cubit.medicineSelected(_catalogItem);
    expect(cubit.state.formData.activeIngredient, isNotEmpty);

    cubit.nameQueryChanged('ama');
    expect(cubit.state.formData.activeIngredient, isEmpty);
  });

  test('isAvailable defaults to true and is sent as entered', () async {
    expect(cubit.state.formData.isAvailable, isTrue);

    cubit.medicineSelected(_catalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');
    cubit.isAvailableChanged(false);

    await cubit.save();

    expect(repository.lastIsAvailable, isFalse);
  });

  test('canSubmit requires a selected medicine, positive quantity and price', () {
    cubit.medicineSelected(_catalogItem);
    expect(cubit.state.formData.canSubmit, isFalse);

    cubit.quantityChanged('20');
    expect(cubit.state.formData.canSubmit, isFalse);

    cubit.priceChanged('25.00');
    expect(cubit.state.formData.canSubmit, isTrue);
  });

  test('canSubmit is false for a non-numeric or non-positive quantity', () {
    cubit.medicineSelected(_catalogItem);
    cubit.priceChanged('25.00');

    cubit.quantityChanged('abc');
    expect(cubit.state.formData.canSubmit, isFalse);

    cubit.quantityChanged('0');
    expect(cubit.state.formData.canSubmit, isFalse);

    cubit.quantityChanged('20');
    expect(cubit.state.formData.canSubmit, isTrue);
  });

  test('imageSelected uploads to Cloudinary and stores the resulting url', () async {
    await cubit.imageSelected(File('medicine.jpg'));

    final formData = cubit.state.formData;
    expect(formData.imageUrl, 'https://res.cloudinary.com/demo/image/upload/a.jpg');
    expect(formData.isUploadingImage, isFalse);
  });

  test('imageSelected surfaces an upload failure', () async {
    imageRepository.result = const ApiError(UnknownFailure('تعذر رفع الصورة'));

    await cubit.imageSelected(File('medicine.jpg'));

    final formData = cubit.state.formData;
    expect(formData.imageUrl, isNull);
    expect(formData.imageError, 'تعذر رفع الصورة');
  });

  test('canSubmit is false while an image upload is in flight', () async {
    final gate = Completer<void>();
    imageRepository.uploadGate = gate;
    cubit.medicineSelected(_catalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');

    final uploadFuture = cubit.imageSelected(File('medicine.jpg'));
    expect(cubit.state.formData.canSubmit, isFalse);

    gate.complete();
    await uploadFuture;
    expect(cubit.state.formData.canSubmit, isTrue);
  });

  test('picking a second image while the first upload is in flight keeps the newer result', () async {
    final firstGate = Completer<void>();
    imageRepository.uploadGate = firstGate;
    final firstUpload = cubit.imageSelected(File('first.jpg'));

    // Second pick starts its own (already-resolved) upload before the first
    // one's gate opens.
    imageRepository
      ..uploadGate = null
      ..result = const Success('https://res.cloudinary.com/demo/image/upload/second.jpg');
    await cubit.imageSelected(File('second.jpg'));

    firstGate.complete();
    await firstUpload;

    expect(cubit.state.formData.imageUrl, 'https://res.cloudinary.com/demo/image/upload/second.jpg');
  });

  test('a failed re-upload does not leave the previous photo silently attached', () async {
    await cubit.imageSelected(File('first.jpg'));
    expect(cubit.state.formData.imageUrl, isNotNull);

    imageRepository.result = const ApiError(UnknownFailure('تعذر رفع الصورة'));
    await cubit.imageSelected(File('second.jpg'));

    final formData = cubit.state.formData;
    expect(formData.imageLocalPath, 'second.jpg');
    expect(formData.imageUrl, isNull);
    expect(formData.imageError, 'تعذر رفع الصورة');
  });

  test('save sends medicine_id for a general-catalog selection', () async {
    cubit.medicineSelected(_catalogItem); // type: 'medicine' (general catalog)
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');

    await cubit.save();

    expect(cubit.state, isA<AddMedicineSuccess>());
    expect(repository.lastMedicineId, 5);
    expect(repository.lastMohMedicineId, isNull);
  });

  test('save sends moh_medicine_id for a Ministry of Health selection', () async {
    cubit.medicineSelected(_mohCatalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');

    await cubit.save();

    expect(cubit.state, isA<AddMedicineSuccess>());
    expect(repository.lastMedicineId, isNull);
    expect(repository.lastMohMedicineId, 21);
  });

  test('save does nothing when the form is incomplete', () async {
    await cubit.save();

    expect(repository.lastMedicineId, isNull);
    expect(cubit.state, isA<AddMedicineEditing>());
  });

  test('save sends the form data (including the uploaded image url) and emits success', () async {
    cubit.medicineSelected(_catalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');
    await cubit.imageSelected(File('medicine.jpg'));

    await cubit.save();

    expect(cubit.state, isA<AddMedicineSuccess>());
    expect(repository.lastMedicineId, 5);
    expect(repository.lastPrice, 25.0);
    expect(repository.lastQuantity, 20);
    expect(repository.lastImageUrl, 'https://res.cloudinary.com/demo/image/upload/a.jpg');
  });

  test('save works without a photo — image is optional', () async {
    cubit.medicineSelected(_catalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');

    await cubit.save();

    expect(cubit.state, isA<AddMedicineSuccess>());
    expect(repository.lastImageUrl, isNull);
  });

  test('save surfaces a repository failure', () async {
    cubit.medicineSelected(_catalogItem);
    cubit.quantityChanged('20');
    cubit.priceChanged('25.00');
    repository.addResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));

    await cubit.save();

    final state = cubit.state as AddMedicineFailure;
    expect(state.message, 'فشل الحفظ');
  });

  group('manual entry (POST /pharmacy/medicines/by-name)', () {
    test('manualEntryToggled switches off the catalog requirement', () {
      cubit.nameQueryChanged('Some Unlisted Drug');
      cubit.manualEntryToggled();

      final formData = cubit.state.formData;
      expect(formData.isManualEntry, isTrue);
      expect(formData.selectedMedicine, isNull);
      // Entering manual entry keeps whatever was already typed as the name.
      expect(formData.nameQuery, 'Some Unlisted Drug');
    });

    test('typing while in manual entry does not trigger a catalog search', () async {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Some Unlisted Drug');

      await Future.delayed(const Duration(milliseconds: 400));

      expect(cubit.state.formData.suggestions, isEmpty);
      expect(cubit.state.formData.isSearching, isFalse);
    });

    test('toggling manual entry off clears the typed name/name_ar/active ingredient', () {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Some Unlisted Drug');
      cubit.nameArChanged('اسم عربي');
      cubit.activeIngredientChanged('Some Active Ingredient');

      cubit.manualEntryToggled();

      final formData = cubit.state.formData;
      expect(formData.isManualEntry, isFalse);
      expect(formData.nameQuery, isEmpty);
      expect(formData.nameAr, isEmpty);
      expect(formData.activeIngredient, isEmpty);
    });

    test('canSubmit rejects an Arabic trade name (backend requires English)', () {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('بانادول');
      cubit.quantityChanged('20');
      cubit.priceChanged('25.00');

      expect(cubit.state.formData.nameHasArabicChars, isTrue);
      expect(cubit.state.formData.canSubmit, isFalse);
    });

    test('canSubmit only requires the English trade name, not name_ar or active ingredient', () {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Some Unlisted Drug');
      cubit.quantityChanged('20');
      cubit.priceChanged('25.00');

      expect(cubit.state.formData.canSubmit, isTrue);
    });

    test('save calls addMedicineByName with trade_name/trade_name_ar/active_ingredient', () async {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Abod panadol');
      cubit.nameArChanged('بانادول أبو');
      cubit.activeIngredientChanged('Paracetamol');
      cubit.quantityChanged('40');
      cubit.priceChanged('12.5');

      await cubit.save();

      expect(cubit.state, isA<AddMedicineSuccess>());
      expect(repository.lastTradeName, 'Abod panadol');
      expect(repository.lastTradeNameAr, 'بانادول أبو');
      expect(repository.lastActiveIngredient, 'Paracetamol');
      expect(repository.lastQuantity, 40);
      expect(repository.lastPrice, 12.5);
      // Must not also hit the by-ID endpoint.
      expect(repository.lastMedicineId, isNull);
      expect(repository.lastMohMedicineId, isNull);
    });

    test('save omits trade_name_ar/active_ingredient when left blank', () async {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Abod panadol');
      cubit.quantityChanged('40');
      cubit.priceChanged('12.5');

      await cubit.save();

      expect(repository.lastTradeNameAr, isNull);
      expect(repository.lastActiveIngredient, isNull);
    });

    test('save surfaces a by-name repository failure', () async {
      cubit.manualEntryToggled();
      cubit.nameQueryChanged('Abod panadol');
      cubit.quantityChanged('40');
      cubit.priceChanged('12.5');
      repository.addByNameResult = const ApiError(ApiFailure(message: 'فشل الحفظ'));

      await cubit.save();

      final state = cubit.state as AddMedicineFailure;
      expect(state.message, 'فشل الحفظ');
    });
  });
}
