import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/searched_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_search_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/search_medicines_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMedicineSearchRepository implements MedicineSearchRepository {
  ApiResult<List<SearchedMedicine>> result = const Success([]);
  String? lastQuery;

  @override
  Future<ApiResult<List<SearchedMedicine>>> search(String query) async {
    lastQuery = query;
    return result;
  }
}

void main() {
  test('passes the query through to the repository, with no token required', () async {
    final repository = _FakeMedicineSearchRepository();
    repository.result = const Success([
      SearchedMedicine(id: 1, tradeName: 'Panadol', isAvailable: true, availablePharmaciesCount: 1),
    ]);
    final useCase = SearchMedicinesUseCase(repository);

    final result = await useCase('panadol');

    expect(repository.lastQuery, 'panadol');
    expect(result, isA<Success<List<SearchedMedicine>>>());
    expect((result as Success).data.single.tradeName, 'Panadol');
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeMedicineSearchRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final useCase = SearchMedicinesUseCase(repository);

    final result = await useCase('panadol');

    expect(result, isA<ApiError<List<SearchedMedicine>>>());
  });
}
