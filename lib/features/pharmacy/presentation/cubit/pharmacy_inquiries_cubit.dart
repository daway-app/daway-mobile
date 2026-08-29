import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/api_result.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/usecases/get_pharmacy_inquiries_usecase.dart';
import '../../domain/usecases/update_inquiry_status_usecase.dart';
import 'pharmacy_inquiries_state.dart';

class PharmacyInquiriesCubit extends Cubit<PharmacyInquiriesState> {
  final GetPharmacyInquiriesUseCase _getPharmacyInquiriesUseCase;
  final UpdateInquiryStatusUseCase _updateInquiryStatusUseCase;

  PharmacyInquiriesCubit(
    this._getPharmacyInquiriesUseCase,
    this._updateInquiryStatusUseCase,
  ) : super(const PharmacyInquiriesLoading()) {
    load();
  }

  /// Carries the previous filter forward across a reload (including the one
  /// after a successful status update) — same reasoning as
  /// PharmacyInventoryCubit.load(): a pharmacist working through one filter
  /// tab shouldn't get bounced back to "الكل" every time they act on a card.
  ///
  /// Only shows the full-screen loading state on a cold start or a retry
  /// from an error — when there's already a loaded list (i.e. this is the
  /// reload after a status update), it stays on screen while the refresh
  /// runs in the background, so acting on one card doesn't blank out every
  /// other card and reset the scroll position.
  Future<void> load() async {
    final previous = state;
    if (previous is! PharmacyInquiriesLoaded) {
      emit(const PharmacyInquiriesLoading());
    }
    final result = await _getPharmacyInquiriesUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          PharmacyInquiriesLoaded(
            inquiries: data.inquiries,
            newCount: data.newCount,
            answeredCount: data.answeredCount,
            closedCount: data.closedCount,
            filter: previous is PharmacyInquiriesLoaded
                ? previous.filter
                : InquiryStatusFilter.all,
          ),
        );
      case ApiError(:final failure):
        emit(PharmacyInquiriesLoadFailure(failure.message));
    }
  }

  void filterChanged(InquiryStatusFilter filter) {
    final current = state;
    if (current is! PharmacyInquiriesLoaded) return;
    emit(current.copyWith(filter: filter));
  }

  /// Returns null on success, or a user-facing error message on failure —
  /// lets the screen show a snackbar without the cubit owning UI feedback.
  Future<String?> updateStatus(int inquiryId, InquiryStatus status) async {
    final current = state;
    if (current is! PharmacyInquiriesLoaded ||
        current.updatingIds.contains(inquiryId)) {
      return null;
    }

    emit(current.copyWith(updatingIds: {...current.updatingIds, inquiryId}));
    final result = await _updateInquiryStatusUseCase(
      inquiryId: inquiryId,
      status: status,
    );
    if (isClosed) return null;

    switch (result) {
      case Success():
        // Reload rather than patch the single item locally: the new/
        // answered/closed counts are server-authoritative (see
        // InquiriesOverview), and reloading is the only way to keep them
        // in sync with the status change instead of drifting.
        await load();
        return null;
      case ApiError(:final failure):
        final latest = state;
        if (latest is PharmacyInquiriesLoaded) {
          emit(
            latest.copyWith(
              updatingIds: latest.updatingIds.difference({inquiryId}),
            ),
          );
        }
        return failure.message;
    }
  }
}
