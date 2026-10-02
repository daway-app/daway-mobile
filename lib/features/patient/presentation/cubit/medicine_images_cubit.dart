import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_medicine_detail_usecase.dart';

/// Images of the medicines in a category listing. The list rows carry no
/// image, but each row's `medicine_id` is a stocked medicine whose detail
/// has one — so cards ask for theirs as they appear, each medicine is
/// fetched once, and the state maps `medicineId -> image URL` (null for a
/// medicine with no image, or one that failed to load).
class MedicineImagesCubit extends Cubit<Map<int, String?>> {
  final GetMedicineDetailUseCase _getMedicineDetailUseCase;
  final Set<int> _requested = {};

  MedicineImagesCubit(this._getMedicineDetailUseCase) : super(const {});

  Future<void> request(int medicineId) async {
    if (!_requested.add(medicineId)) return;

    final result = await _getMedicineDetailUseCase(medicineId: medicineId);
    if (isClosed) return;

    final imageUrl = switch (result) {
      Success(:final data) => data.imageUrl,
      ApiError() => null,
    };
    emit({...state, medicineId: imageUrl});
  }
}
