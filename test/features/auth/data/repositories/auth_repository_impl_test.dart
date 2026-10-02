import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:daway_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends AuthRemoteDataSource {
  Map<String, dynamic> sendOtpBody = {'success': true, 'otp': '123456', 'is_registered': true};
  Map<String, dynamic> registerBody = {'success': true, 'otp': '654321', 'is_registered': false};
  bool registerCalled = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> sendOtp({required String phone}) async =>
      Response(requestOptions: RequestOptions(), data: sendOtpBody, statusCode: 200);

  @override
  Future<Response<dynamic>> registerPatient({
    required String phone,
    required String name,
    required int age,
  }) async {
    registerCalled = true;
    return Response(requestOptions: RequestOptions(), data: registerBody, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _StubRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  test('login for a registered phone returns the OTP', () async {
    final result = await repository.sendOtp(phone: '0599123456');

    expect((result as Success).data, '123456');
  });

  test('login for a phone with no account is stopped before the OTP step', () async {
    dataSource.sendOtpBody = {'success': true, 'otp': '123456', 'is_registered': false};

    final result = await repository.sendOtp(phone: '0599123456');

    final failure = (result as ApiError).failure as ApiFailure;
    expect(failure.registrationRequired, isTrue);
    expect(failure.message, contains('لا يوجد حساب'));
  });

  test('sign-up uses the register endpoint and an unregistered phone is expected', () async {
    final result = await repository.sendOtp(
      phone: '0599000001',
      name: 'محمد',
      birthDate: '2000-01-01',
    );

    expect(dataSource.registerCalled, isTrue);
    expect((result as Success).data, '654321');
  });
}
