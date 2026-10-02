import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../chat/presentation/cubit/conversations_cubit.dart';
import '../../../chat/presentation/widgets/conversations_view.dart';

/// "الاستفسارات" tab: the pharmacy's conversations with patients, in the same
/// design as the patient's list.
class PharmacyConversationsScreen extends StatelessWidget {
  const PharmacyConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => getIt<ConversationsCubit>(instanceName: 'pharmacy'),
        child: const ConversationsView(
          title: 'الاستفسارات',
          description: 'راجع استفسارات المرضى وردّ عليها.',
          emptyText: 'لا توجد استفسارات بعد.',
        ),
      ),
    );
  }
}
