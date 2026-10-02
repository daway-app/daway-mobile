import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/patient_addresses_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/patient_addresses_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends PatientAddressesRemoteDataSource {
  Object? nextGetResponse;
  Object? nextCreateResponse;
  Object? nextUpdateResponse;
  bool getThrows = false;
  bool createThrows = false;
  bool updateThrows = false;
  int? lastUpdatedAddressId;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getAddresses({required String token}) async {
    if (getThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextGetResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    if (createThrows) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextCreateResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> updateAddress({
    required String token,
    required int addressId,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    if (updateThrows) throw DioException(requestOptions: RequestOptions());
    lastUpdatedAddressId = addressId;
    return Response(requestOptions: RequestOptions(), data: nextUpdateResponse, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late PatientAddressesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = PatientAddressesRepositoryImpl(remoteDataSource);
  });

  group('getAddresses', () {
    test('parses the address rows out of the data list', () async {
      remoteDataSource.nextGetResponse = {
        'success': true,
        'data': [
          {'id': 1, 'label': 'المنزل', 'address': 'غزة', 'is_default': true},
        ],
      };

      final result = await repository.getAddresses(token: 'tok');

      expect(result, isA<Success<Object?>>());
      final addresses = (result as Success).data;
      expect(addresses, hasLength(1));
      expect(addresses.single.label, 'المنزل');
    });

    test('an empty address book is a valid, non-error result', () async {
      remoteDataSource.nextGetResponse = {'success': true, 'data': <dynamic>[]};

      final result = await repository.getAddresses(token: 'tok');

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data, isEmpty);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.getThrows = true;

      final result = await repository.getAddresses(token: 'tok');

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('createAddress', () {
    test('parses the created address out of the data envelope', () async {
      remoteDataSource.nextCreateResponse = {
        'success': true,
        'data': {'id': 1, 'label': 'المنزل', 'address': 'غزة', 'is_default': true},
      };

      final result = await repository.createAddress(
        token: 'tok',
        label: 'المنزل',
        recipientName: 'مريض',
        phone: '0599112233',
        address: 'غزة',
        latitude: 31.5,
        longitude: 34.47,
      );

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data.id, 1);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.createThrows = true;

      final result = await repository.createAddress(
        token: 'tok',
        label: 'المنزل',
        recipientName: 'مريض',
        phone: '0599112233',
        address: 'غزة',
        latitude: 31.5,
        longitude: 34.47,
      );

      expect(result, isA<ApiError<Object?>>());
    });
  });

  group('updateAddress', () {
    test('sends the address id and parses the updated address out of the data envelope',
        () async {
      remoteDataSource.nextUpdateResponse = {
        'success': true,
        'data': {'id': 1, 'label': 'المنزل', 'address': 'خان يونس', 'is_default': true},
      };

      final result = await repository.updateAddress(
        token: 'tok',
        addressId: 1,
        label: 'المنزل',
        recipientName: 'مريض',
        phone: '0599112233',
        address: 'خان يونس',
        latitude: 31.3,
        longitude: 34.3,
        isDefault: true,
      );

      expect(result, isA<Success<Object?>>());
      expect((result as Success).data.address, 'خان يونس');
      expect(remoteDataSource.lastUpdatedAddressId, 1);
    });

    test('surfaces a network failure instead of throwing', () async {
      remoteDataSource.updateThrows = true;

      final result = await repository.updateAddress(
        token: 'tok',
        addressId: 1,
        label: 'المنزل',
        recipientName: 'مريض',
        phone: '0599112233',
        address: 'خان يونس',
        latitude: 31.3,
        longitude: 34.3,
        isDefault: true,
      );

      expect(result, isA<ApiError<Object?>>());
    });
  });
}
