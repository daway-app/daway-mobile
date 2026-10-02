import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../chat/presentation/cubit/conversations_cubit.dart';
import '../../../chat/presentation/widgets/conversations_view.dart';

/// "المراسلات" tab: the patient's conversations with pharmacies. Has no
/// Scaffold of its own, like the other dashboard tabs (the shell supplies the
/// bottom nav).
class PatientConversationsScreen extends StatelessWidget {
  const PatientConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationsCubit>(instanceName: 'patient'),
      child: const ConversationsView(
        title: 'الاستشارات',
        description: 'راجع استفساراتك للصيدليات وردودها.',
        emptyText:
            'لا توجد مراسلات بعد.\nافتح صفحة أي دواء واضغط «اسأل الصيدلية قبل الشراء».',
      ),
    );
  }
}
