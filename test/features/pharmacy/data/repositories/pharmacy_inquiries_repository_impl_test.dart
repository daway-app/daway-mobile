import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/pharmacy/data/datasources/pharmacy_inquiries_remote_data_source.dart';
import 'package:daway_app/features/pharmacy/data/repositories/pharmacy_inquiries_repository_impl.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks in the wire shape confirmed against a live `GET /pharmacy/inquiries`
/// response: a flat `data` list plus a `counts` object with the true
/// new/answered/closed totals.
class _StubRemoteDataSource extends PharmacyInquiriesRemoteDataSource {
  Object? nextGetResponse;
  bool getThrows = false;
  bool updateThrows = false;
  Map<String, dynamic>? lastUpdateBody;
  int? lastUpdateId;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getInquiries({required String token}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    return Response(
      requestOptions: RequestOptions(),
      data: nextGetResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> updateStatus({
    required String token,
    required int inquiryId,
    required String status,
  }) async {
    if (updateThrows) throw DioException(requestOptions: RequestOptions());
    lastUpdateId = inquiryId;
    lastUpdateBody = {'status': status};
    return Response(requestOptions: RequestOptions(), statusCode: 200);
  }
}

const _responseJson = {
  'data': [
    {
      'id': 1,
      'status': 'new',
      'message': 'هل يتوفر هذا الدواء؟',
      'created_at': '2026-08-22 16:32:25',
      'user': {'id': 36, 'name': 'أحمد الحربي'},
      'medicine': {'id': 6, 'trade_name': 'Panadol 500mg'},
    },
  ],
  'counts': {'new': 3, 'answered': 18, 'closed': 42},
  'pagination': {
    'total': 63,
    'per_page': 100,
    'current_page': 1,
    'last_page': 1,
  },
};

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PharmacyInquiriesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PharmacyInquiriesRepositoryImpl(remoteDataSource);
    remoteDataSource.nextGetResponse = _responseJson;
  });

  test('parses the inquiries list and the authoritative counts', () async {
    final result = await repository.getInquiries(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
    final overview = (result as Success).data;
    expect(overview.newCount, 3);
    expect(overview.answeredCount, 18);
    expect(overview.closedCount, 42);
    expect(overview.inquiries, hasLength(1));
    final inquiry = overview.inquiries.single;
    expect(inquiry.id, 1);
    expect(inquiry.status, InquiryStatus.newInquiry);
    expect(inquiry.patientName, 'أحمد الحربي');
    expect(inquiry.medicineName, 'Panadol 500mg');
  });

  test(
    'a malformed record among otherwise-valid inquiries is skipped, not fatal',
    () async {
      remoteDataSource.nextGetResponse = {
        'data': [
          {
            'id': 1,
            'status': 'new',
            'message': 'سؤال',
            'created_at': '2026-08-22 16:32:25',
            'user': {'id': 36, 'name': 'أحمد'},
          },
          {'id': 2, 'medicine': 'not-an-object'},
        ],
        'counts': {'new': 1, 'answered': 0, 'closed': 0},
      };

      final result = await repository.getInquiries(token: 'tok-1');

      final overview = (result as Success).data;
      expect(overview.inquiries, hasLength(1));
      expect(overview.inquiries.single.id, 1);
    },
  );

  test('a network failure surfaces as an ApiError', () async {
    remoteDataSource.getThrows = true;

    final result = await repository.getInquiries(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test(
    'updateInquiryStatus sends the wire status string for the given id',
    () async {
      final result = await repository.updateInquiryStatus(
        token: 'tok-1',
        inquiryId: 7,
        status: InquiryStatus.answered,
      );

      expect(result, isA<Success<Object?>>());
      expect(remoteDataSource.lastUpdateId, 7);
      expect(remoteDataSource.lastUpdateBody, {'status': 'answered'});
    },
  );

  test('updateInquiryStatus surfaces a failure as an ApiError', () async {
    remoteDataSource.updateThrows = true;

    final result = await repository.updateInquiryStatus(
      token: 'tok-1',
      inquiryId: 7,
      status: InquiryStatus.closed,
    );

    expect(result, isA<ApiError<Object?>>());
  });
}
