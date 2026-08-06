import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountTypeCubit', () {
    test('initial state is AccountType.patient', () {
      final cubit = AccountTypeCubit();

      expect(cubit.state, AccountType.patient);

      cubit.close();
    });

    test('selectAccountType emits the selected type', () async {
      final cubit = AccountTypeCubit();
      final emittedStates = <AccountType>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      cubit.selectAccountType(AccountType.pharmacy);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, AccountType.pharmacy);
      expect(emittedStates, [AccountType.pharmacy]);

      await subscription.cancel();
      await cubit.close();
    });
  });
}
