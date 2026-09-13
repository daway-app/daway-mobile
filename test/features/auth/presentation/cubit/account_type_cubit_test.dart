import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:daway_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:daway_app/features/onboarding/domain/usecases/get_onboarding_seen_usecase.dart';
import 'package:daway_app/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  final Set<AccountType> seenTypes = {};

  @override
  Future<bool> isOnboardingSeen(AccountType accountType) async =>
      seenTypes.contains(accountType);

  @override
  Future<void> setOnboardingSeen(AccountType accountType) async {
    seenTypes.add(accountType);
  }
}

void main() {
  late _FakeOnboardingRepository repository;
  late AccountTypeCubit cubit;

  setUp(() {
    repository = _FakeOnboardingRepository();
    cubit = AccountTypeCubit(
      GetOnboardingSeenUseCase(repository),
      SetOnboardingSeenUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  group('AccountTypeCubit', () {
    test('initial state is AccountType.patient', () {
      expect(cubit.state, AccountType.patient);
    });

    test('selectAccountType emits the selected type', () async {
      final emittedStates = <AccountType>[];
      final subscription = cubit.stream.listen(emittedStates.add);

      cubit.selectAccountType(AccountType.pharmacy);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, AccountType.pharmacy);
      expect(emittedStates, [AccountType.pharmacy]);

      await subscription.cancel();
    });

    test('hasSeenOnboarding reflects the repository per account type', () async {
      expect(await cubit.hasSeenOnboarding(AccountType.patient), isFalse);

      await cubit.markOnboardingSeen(AccountType.patient);

      expect(await cubit.hasSeenOnboarding(AccountType.patient), isTrue);
      expect(await cubit.hasSeenOnboarding(AccountType.pharmacy), isFalse);
    });
  });
}
