import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/searched_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_search_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/search_medicines_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_search_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_search_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _results = [
  SearchedMedicine(id: 1, tradeName: 'Panadol', isAvailable: true, availablePharmaciesCount: 1),
];

class _FakeMedicineSearchRepository implements MedicineSearchRepository {
  ApiResult<List<SearchedMedicine>> result = const Success(_results);

  @override
  Future<ApiResult<List<SearchedMedicine>>> search(String query) async => result;
}

/// Answers each query only when the test says so, to control which response
/// arrives first.
class _ControlledSearchRepository implements MedicineSearchRepository {
  final Map<String, Completer<ApiResult<List<SearchedMedicine>>>> pending = {};

  @override
  Future<ApiResult<List<SearchedMedicine>>> search(String query) {
    final completer = Completer<ApiResult<List<SearchedMedicine>>>();
    pending[query] = completer;
    return completer.future;
  }
}

SearchedMedicine _medicine(String name) =>
    SearchedMedicine(id: 1, tradeName: name, isAvailable: true, availablePharmaciesCount: 1);

void main() {
  late _FakeMedicineSearchRepository repository;
  late MedicineSearchCubit cubit;

  setUp(() {
    repository = _FakeMedicineSearchRepository();
    cubit = MedicineSearchCubit(SearchMedicinesUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('starts idle, with no request made until a query is searched', () {
    expect(cubit.state, isA<MedicineSearchIdle>());
  });

  test('search() loads and emits the matching medicines', () async {
    await cubit.search('panadol');

    expect(cubit.state, isA<MedicineSearchLoaded>());
    final loaded = cubit.state as MedicineSearchLoaded;
    expect(loaded.query, 'panadol');
    expect(loaded.results, _results);
  });

  test('an empty query resets to idle instead of searching for nothing', () async {
    await cubit.search('panadol');
    expect(cubit.state, isA<MedicineSearchLoaded>());

    await cubit.search('   ');

    expect(cubit.state, isA<MedicineSearchIdle>());
  });

  test('surfaces a load failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.search('panadol');

    expect(cubit.state, isA<MedicineSearchLoadFailure>());
    expect((cubit.state as MedicineSearchLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('a later search replaces an earlier failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    await cubit.search('panadol');
    expect(cubit.state, isA<MedicineSearchLoadFailure>());

    repository.result = const Success(_results);
    await cubit.search('panadol');

    expect(cubit.state, isA<MedicineSearchLoaded>());
  });

  group('responses that arrive out of order', () {
    late _ControlledSearchRepository controlled;
    late MedicineSearchCubit controlledCubit;

    setUp(() {
      controlled = _ControlledSearchRepository();
      controlledCubit = MedicineSearchCubit(SearchMedicinesUseCase(controlled));
    });

    tearDown(() => controlledCubit.close());

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('a late response for a query the user has since cleared does not bring its results back', () async {
      final inFlight = controlledCubit.search('pan');
      await settle();

      await controlledCubit.search(''); // the field was cleared
      expect(controlledCubit.state, isA<MedicineSearchIdle>());

      controlled.pending['pan']!.complete(Success([_medicine('Panadol')]));
      await inFlight;

      expect(controlledCubit.state, isA<MedicineSearchIdle>());
    });

    test('the latest query wins even when an older one finishes last', () async {
      final older = controlledCubit.search('pa');
      await settle();
      final newer = controlledCubit.search('pan');
      await settle();

      controlled.pending['pan']!.complete(Success([_medicine('Panadol')]));
      await newer;
      controlled.pending['pa']!.complete(Success([_medicine('Paracetamol')]));
      await older;

      final loaded = controlledCubit.state as MedicineSearchLoaded;
      expect(loaded.query, 'pan');
      expect(loaded.results.single.tradeName, 'Panadol');
    });

    test('a late failure of an older query does not replace the newer results', () async {
      final older = controlledCubit.search('pa');
      await settle();
      final newer = controlledCubit.search('pan');
      await settle();

      controlled.pending['pan']!.complete(Success([_medicine('Panadol')]));
      await newer;
      controlled.pending['pa']!.complete(const ApiError(NetworkFailure('انقطع الاتصال')));
      await older;

      expect(controlledCubit.state, isA<MedicineSearchLoaded>());
    });

    test('closing while a search is in flight does not throw', () async {
      final inFlight = controlledCubit.search('pan');
      await settle();

      await controlledCubit.close();
      controlled.pending['pan']!.complete(Success([_medicine('Panadol')]));
      await inFlight;
      await settle();

      // Reaching here means no uncaught "emit after close" error failed the test.
      expect(controlledCubit.isClosed, isTrue);
    });
  });
}
