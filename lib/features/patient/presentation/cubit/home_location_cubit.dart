import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/usecases/get_current_location_usecase.dart';

/// The address shown under the greeting on the home screen, read from the
/// device's GPS position (latitude/longitude reverse-geocoded to a place
/// name). State is the address text, or null while unknown — denied
/// permission, GPS off, or no fix just leaves the "حدد موقعك" fallback.
class HomeLocationCubit extends Cubit<String?> {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  HomeLocationCubit(this._getCurrentLocationUseCase) : super(null) {
    load();
  }

  Future<void> load() async {
    final result = await _getCurrentLocationUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(data.address.isEmpty ? null : data.address);
      case ApiError():
        emit(null);
    }
  }
}
