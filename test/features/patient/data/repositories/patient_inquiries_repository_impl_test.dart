import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/patient_inquiries_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/patient_inquiries_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PatientInquiriesRemoteDataSource {
  /// Response for page 1 when [pageResponses] has no explicit entry for it.
  Object? nextGetResponse;

  /// Explicit per-page responses — set these to test multi-page walks.
  final Map<int, Object?> pageResponses = {};
  Object? nextCreateResponse;
  bool getThrows = false;
  bool createThrows = false;
  int? lastPharmacyId;
  int? lastMedicineId;
  String? lastMessage;
  final List<int> requestedPages = [];

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getInquiries({required String token, int page = 1}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    requestedPages.add(page);
    final data = pageResponses[page] ?? (page == 1 ? nextGetResponse : null);
    return Response(requestOptions: RequestOptions(), data: data, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async {
    if (createThrows) throw DioException(requestOptions: RequestOptions());
    lastPharmacyId = pharmacyId;
    lastMedicineId = medicineId;
    lastMessage = message;
    return Response(requestOptions: RequestOptions(), data: nextCreateResponse, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PatientInquiriesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PatientInquiriesRepositoryImpl(remoteDataSource);
  });

  group('getInquiries', () {
    test('parses the inquiry rows out of the data list', () async {
      remoteDataSource.nextGetResponse = {
        'success': true,
        'data': [
          {
            'id': 1,
            'status': 'new',
            'message': 'سؤال',
            'created_at': '2026-09-29 10:57:43',
            'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
            'medicine': {'id': 6, 'trade_name': 'Panadol'},
          },
        ],
        'pagination': {'total': 1},
      };

      final result = await repository.getInquiries(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final inquiries = (result as Success).data;
      expect(inquiries, hasLength(1));
      expect(inquiries.single.message, 'سؤال');
    });

    test('walks every page instead of only returning the first 20 inquiries', () async {
      remoteDataSource.pageResponses[1] = {
        'success': true,
        'data': [
          {
            'id': 1,
            'status': 'new',
            'message': 'سؤال قديم',
            'created_at': '2026-09-01 10:00:00',
            'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
            'medicine': {'id': 6, 'trade_name': 'Panadol'},
          },
        ],
        'pagination': {'total': 2, 'last_page': 2},
      };
      remoteDataSource.pageResponses[2] = {
        'success': true,
        'data': [
          {
            'id': 2,
            'status': 'answered',
            'message': 'سؤال جديد',
            'created_at': '2026-09-29 10:00:00',
            'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
            'medicine': {'id': 6, 'trade_name': 'Panadol'},
          },
        ],
        'pagination': {'total': 2, 'last_page': 2},
      };

      final result = await repository.getInquiries(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final inquiries = (result as Success).data;
      expect(inquiries.map((i) => i.id), [1, 2]);
      expect(remoteDataSource.requestedPages, [1, 2]);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.getThrows = true;

      final result = await repository.getInquiries(token: 'tok');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('createInquiry', () {
    test('sends the pharmacy id, medicine id and message, and parses the created inquiry',
        () async {
      remoteDataSource.nextCreateResponse = {
        'success': true,
        'data': {
          'id': 1,
          'status': 'new',
          'message': 'هل يتوفر؟',
          'created_at': '2026-09-29 10:57:43',
          'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
          'medicine': {'id': 6, 'trade_name': 'Panadol'},
        },
      };

      final result = await repository.createInquiry(
        token: 'tok',
        pharmacyId: 1,
        medicineId: 6,
        message: 'هل يتوفر؟',
      );

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data.message, 'هل يتوفر؟');
      expect(remoteDataSource.lastPharmacyId, 1);
      expect(remoteDataSource.lastMedicineId, 6);
      expect(remoteDataSource.lastMessage, 'هل يتوفر؟');
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.createThrows = true;

      final result = await repository.createInquiry(
        token: 'tok',
        pharmacyId: 1,
        medicineId: 6,
        message: 'هل يتوفر؟',
      );

      expect(result, isA<ApiError<Object?>>());
    });
  });
}
