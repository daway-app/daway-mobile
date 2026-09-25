import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/repositories/app_info_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('returns the installed app version name, without the build number', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Daway',
      packageName: 'ps.daway.app',
      version: '2.3.4',
      buildNumber: '17',
      buildSignature: '',
    );

    final result = await const AppInfoRepositoryImpl().getVersion();

    expect(result, isA<Success<String>>());
    expect((result as Success<String>).data, '2.3.4');
  });
}
