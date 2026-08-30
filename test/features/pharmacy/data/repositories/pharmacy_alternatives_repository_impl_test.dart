import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_alternatives_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_alternatives_repository_impl.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PharmacyAlternativesRemoteDataSource {
  Object? nextCandidatesResponse;
  Object? nextLinksResponse;
  bool candidatesThrow = false;
  bool linksThrow = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getCandidates({
    required String token,
    required int pharmacyMedicineId,
  }) async {
    if (candidatesThrow) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextCandidatesResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> getLinks({required String token}) async {
    if (linksThrow) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextLinksResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> create({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }

  @override
  Future<Response<dynamic>> delete({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }
}

const _baseMedicine = Medicine(
  id: 14,
  medicineId: 17,
  name: 'بندل',
  activeIngredient: 'بمبو',
  price: 40,
  quantity: 8,
  isAvailable: true,
  isLowStock: true,
);

/// Confirmed against a live `GET /pharmacy/medicines/{id}/alternatives`
/// response: each candidate is a sparse `{id, trade_name, active_ingredient}`
/// object — no price/quantity/availability/Arabic name — and `id` here is
/// the candidate's **catalog** medicine id (19 = Moxclav's `medicine_id`),
/// not a `pharmacy_medicine` stock-row id.
const _moxclavCandidateJson = {
  'id': 19,
  'trade_name': 'Moxclav',
  'active_ingredient': 'بمبو',
};

/// What `GET /pharmacy/medicines` (fetched separately by
/// GetAlternativesOverviewUseCase and passed in as `allMedicines`) has on
/// file for that same Moxclav stock row — a full pharmacy_medicine record,
/// keyed by its own `id` (16, a different id space from the catalog id 19).
const _moxclavStockEntry = Medicine(
  id: 16,
  medicineId: 19,
  name: 'Moxclav',
  activeIngredient: 'بمبو',
  price: 60,
  quantity: 20,
  isAvailable: true,
);

const _allMedicines = [_baseMedicine, _moxclavStockEntry];

/// Shape confirmed against a live `GET /pharmacy/alternatives` response:
/// grouped by base medicine (the top-level `id` is the base medicine's own
/// `pharmacy_medicine` id), with linked alternatives nested underneath — not
/// a flat list of `{base_medicine_id, alternative_id}` pairs. Each nested
/// `alternatives[].id` is that alternative's catalog medicine id (matching
/// the candidates endpoint), so this uses the same `19` as
/// [_moxclavCandidateJson] rather than Moxclav's pharmacy_medicine id (16).
const _linksJsonWithMoxclavSelectedOnBase14 = {
  'data': [
    {
      'id': 14,
      'pharmacy_id': 6,
      'medicine_id': 17,
      'price': 40,
      'quantity': 8,
      'medicine': {'trade_name': 'بندل', 'active_ingredient': 'بمبو'},
      'alternatives': [
        {'id': 19, 'trade_name': 'Moxclav', 'active_ingredient': 'بمبو'},
      ],
    },
  ],
};

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PharmacyAlternativesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PharmacyAlternativesRepositoryImpl(remoteDataSource);
    remoteDataSource.nextCandidatesResponse = {
      'data': [_moxclavCandidateJson],
    };
    remoteDataSource.nextLinksResponse = {'data': []};
  });

  test(
    'hydrates a sparse candidate into a full Medicine by matching its catalog id against allMedicines',
    () async {
      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: _allMedicines,
      );

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.candidates, hasLength(1));
      final candidate = overview.candidates.single;
      expect(candidate.name, 'Moxclav');
      expect(candidate.price, 60);
      expect(candidate.quantity, 20);
      // The candidate's id is its own pharmacy_medicine stock-row id (16,
      // from allMedicines) — same meaning as everywhere else Medicine.id is
      // used in the app. Its catalog id (19, what select/remove and the
      // selected-ids set actually key on) lives on medicineId instead.
      expect(candidate.id, 16);
      expect(candidate.medicineId, 19);
    },
  );

  test(
    'baseMedicine is re-hydrated from allMedicines, not echoed back stale',
    () async {
      const freshBaseMedicine = Medicine(
        id: 14,
        medicineId: 17,
        name: 'بندل',
        activeIngredient: 'بمبو',
        price: 40,
        quantity: 0,
        isAvailable: true,
        isOutOfStock: true,
      );

      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine, // stale: quantity 8, isLowStock
        allMedicines: [freshBaseMedicine, _moxclavStockEntry],
      );

      final overview = (result as Success).data;
      expect(overview.baseMedicine.quantity, 0);
      expect(overview.baseMedicine.status, MedicineStatus.outOfStock);
    },
  );

  test(
    'falls back to the passed-in baseMedicine if it has gone missing from allMedicines',
    () async {
      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: [_moxclavStockEntry], // no entry for id 14
      );

      final overview = (result as Success).data;
      expect(overview.baseMedicine, _baseMedicine);
    },
  );

  test(
    'a candidate whose catalog id has no match in allMedicines is dropped, not crashed',
    () async {
      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: const [_baseMedicine], // no entry for catalog id 19
      );

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.candidates, isEmpty);
    },
  );

  test(
    'marks a candidate selected from the nested alternatives array on this base medicine\'s own entry',
    () async {
      remoteDataSource.nextLinksResponse =
          _linksJsonWithMoxclavSelectedOnBase14;

      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: _allMedicines,
      );

      final overview = (result as Success).data;
      expect(overview.selectedAlternativeIds, {19});
    },
  );

  test('ignores a different base medicine\'s entry entirely', () async {
    remoteDataSource.nextLinksResponse = {
      'data': [
        {
          'id': 99, // a different base medicine, not this one (14)
          'alternatives': [
            {'id': 19},
          ],
        },
      ],
    };

    final result = await repository.getAlternativesOverview(
      token: 'tok-1',
      baseMedicine: _baseMedicine,
      allMedicines: _allMedicines,
    );

    final overview = (result as Success).data;
    expect(overview.selectedAlternativeIds, isEmpty);
  });

  test(
    'a candidates-endpoint failure fails the whole call — it is the primary content',
    () async {
      remoteDataSource.candidatesThrow = true;

      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: _allMedicines,
      );

      expect(result, isA<ApiError<Object?>>());
    },
  );

  test(
    'a links-endpoint failure degrades to no pre-selected candidate, not a failed call',
    () async {
      remoteDataSource.linksThrow = true;

      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: _allMedicines,
      );

      expect(result, isA<Success<Object?>>());
      final overview = (result as Success).data;
      expect(overview.candidates, hasLength(1));
      expect(overview.selectedAlternativeIds, isEmpty);
    },
  );

  test(
    'a malformed base-medicine entry is skipped instead of failing the cross-reference',
    () async {
      remoteDataSource.nextLinksResponse = {
        'data': [
          {'id': 'not-a-number', 'alternatives': []},
          ..._linksJsonWithMoxclavSelectedOnBase14['data']!,
        ],
      };

      final result = await repository.getAlternativesOverview(
        token: 'tok-1',
        baseMedicine: _baseMedicine,
        allMedicines: _allMedicines,
      );

      final overview = (result as Success).data;
      expect(overview.selectedAlternativeIds, {19});
    },
  );

  test(
    'getBaseMedicineIdsWithAlternatives collects every base medicine with at least one link',
    () async {
      remoteDataSource.nextLinksResponse = {
        'data': [
          {
            'id': 14,
            'alternatives': [
              {'id': 19},
            ],
          },
          {
            'id': 22,
            'alternatives': [
              {'id': 5},
              {'id': 6},
            ],
          },
          // A base medicine with no linked alternatives shouldn't count as
          // "already handled".
          {'id': 30, 'alternatives': []},
        ],
      };

      final result = await repository.getBaseMedicineIdsWithAlternatives(
        token: 'tok-1',
      );

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, {14, 22});
    },
  );

  test(
    'getBaseMedicineIdsWithAlternatives degrades to an empty set on a network failure',
    () async {
      remoteDataSource.linksThrow = true;

      final result = await repository.getBaseMedicineIdsWithAlternatives(
        token: 'tok-1',
      );

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, isEmpty);
    },
  );
}
