import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_detail.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_pharmacy_offer.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_detail_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_medicine_detail_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_images_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements MedicineDetailRepository {
  final Map<int, ApiResult<MedicineDetail>> results = {};
  final List<int> calls = [];

  @override
  Future<ApiResult<MedicineDetail>> getMedicineDetail({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    calls.add(medicineId);
    return results[medicineId] ?? const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
  }

  @override
  Future<ApiResult<List<MedicinePharmacyOffer>>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) =>
      throw UnimplementedError();
}

void main() {
  late _FakeRepository repository;

  MedicineImagesCubit build() {
    final cubit = MedicineImagesCubit(GetMedicineDetailUseCase(repository));
    addTearDown(cubit.close);
    return cubit;
  }

  setUp(() => repository = _FakeRepository());

  test('stores the image of the medicine behind a category row', () async {
    repository.results[8] = const Success(
      MedicineDetail(id: 8, tradeName: 'Brufen', imageUrl: 'https://example.com/b.jpg'),
    );
    final cubit = build();

    await cubit.request(8);

    expect(cubit.state[8], 'https://example.com/b.jpg');
  });

  test('each medicine is fetched once, however often it is requested', () async {
    repository.results[8] = const Success(MedicineDetail(id: 8, tradeName: 'Brufen'));
    final cubit = build();

    await Future.wait([cubit.request(8), cubit.request(8)]);
    await cubit.request(8);

    expect(repository.calls, [8]);
  });

  test('a medicine without an image, or that fails to load, maps to null', () async {
    repository.results[1] = const Success(MedicineDetail(id: 1, tradeName: 'A'));
    final cubit = build();

    await cubit.request(1);
    await cubit.request(2);

    expect(cubit.state.containsKey(1), isTrue);
    expect(cubit.state[1], isNull);
    expect(cubit.state.containsKey(2), isTrue);
    expect(cubit.state[2], isNull);
  });
}
