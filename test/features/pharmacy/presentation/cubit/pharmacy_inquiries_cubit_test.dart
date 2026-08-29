import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inquiries_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_inquiries_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_inquiry_status_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inquiries_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inquiries_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _newInquiry = Inquiry(
  id: 1,
  message: 'هل يتوفر؟',
  status: InquiryStatus.newInquiry,
  createdAt: DateTime(2026, 8, 22),
  patientName: 'أحمد',
);
final _answeredInquiry = Inquiry(
  id: 2,
  message: 'متوفر للأطفال؟',
  status: InquiryStatus.answered,
  createdAt: DateTime(2026, 8, 21),
  patientName: 'سارة',
);
final _closedInquiry = Inquiry(
  id: 3,
  message: 'شكراً',
  status: InquiryStatus.closed,
  createdAt: DateTime(2026, 5, 3),
  patientName: 'محمد',
);

class _FakePharmacyInquiriesRepository implements PharmacyInquiriesRepository {
  ApiResult<InquiriesOverview> getResult = Success(
    InquiriesOverview(
      inquiries: [_newInquiry, _answeredInquiry, _closedInquiry],
      newCount: 1,
      answeredCount: 1,
      closedCount: 1,
    ),
  );
  ApiResult<void> updateResult = const Success(null);
  int updateCallCount = 0;
  int? lastUpdatedId;
  InquiryStatus? lastUpdatedStatus;

  /// When set, updateInquiryStatus() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-update to exercise the
  /// updatingIds guard against a duplicate tap.
  Completer<void>? updateGate;

  @override
  Future<ApiResult<InquiriesOverview>> getInquiries({
    required String token,
  }) async => getResult;

  @override
  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
  }) async {
    updateCallCount++;
    lastUpdatedId = inquiryId;
    lastUpdatedStatus = status;
    if (updateGate != null) await updateGate!.future;
    return updateResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(
    accountType: AccountType.pharmacy,
    token: 'tok-1',
  );

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

void main() {
  late _FakePharmacyInquiriesRepository repository;
  late PharmacyInquiriesCubit cubit;

  setUp(() async {
    repository = _FakePharmacyInquiriesRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyInquiriesCubit(
      GetPharmacyInquiriesUseCase(repository, sessionRepository),
      UpdateInquiryStatusUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads inquiries with the authoritative counts', () {
    final state = cubit.state as PharmacyInquiriesLoaded;
    expect(state.inquiries, hasLength(3));
    expect(state.newCount, 1);
    expect(state.answeredCount, 1);
    expect(state.closedCount, 1);
    expect(state.filter, InquiryStatusFilter.all);
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(
      NetworkFailure('تعذر الاتصال بالخادم'),
    );

    await cubit.load();

    expect(cubit.state, isA<PharmacyInquiriesLoadFailure>());
  });

  test('filterChanged narrows the list by status', () {
    cubit.filterChanged(InquiryStatusFilter.newInquiry);

    final state = cubit.state as PharmacyInquiriesLoaded;
    expect(state.filteredInquiries, [_newInquiry]);
  });

  test(
    'updateStatus calls the use case with the given id and status',
    () async {
      final error = await cubit.updateStatus(1, InquiryStatus.answered);

      expect(error, isNull);
      expect(repository.lastUpdatedId, 1);
      expect(repository.lastUpdatedStatus, InquiryStatus.answered);
    },
  );

  test('updateStatus reloads on success, clearing updatingIds', () async {
    await cubit.updateStatus(1, InquiryStatus.answered);

    final state = cubit.state as PharmacyInquiriesLoaded;
    expect(state.updatingIds, isEmpty);
    expect(repository.updateCallCount, 1);
  });

  test(
    'load (including the reload after a status update) preserves the filter',
    () async {
      cubit.filterChanged(InquiryStatusFilter.newInquiry);

      await cubit.updateStatus(1, InquiryStatus.answered);

      final state = cubit.state as PharmacyInquiriesLoaded;
      expect(state.filter, InquiryStatusFilter.newInquiry);
    },
  );

  test(
    'updateStatus returns an error message and keeps the item on failure',
    () async {
      repository.updateResult = const ApiError(
        ApiFailure(message: 'فشل التحديث'),
      );

      final error = await cubit.updateStatus(1, InquiryStatus.answered);

      expect(error, 'فشل التحديث');
      final state = cubit.state as PharmacyInquiriesLoaded;
      expect(state.updatingIds, isEmpty);
      // Reload wasn't triggered on failure, so the original list is untouched.
      expect(state.inquiries, hasLength(3));
    },
  );

  test(
    'a second updateStatus call for the same id while one is in flight is a no-op',
    () async {
      repository.updateGate = Completer<void>();

      final firstUpdate = cubit.updateStatus(1, InquiryStatus.answered);
      final secondResult = await cubit.updateStatus(1, InquiryStatus.closed);

      expect(secondResult, isNull);
      repository.updateGate!.complete();
      await firstUpdate;

      expect(repository.updateCallCount, 1);
    },
  );
}
