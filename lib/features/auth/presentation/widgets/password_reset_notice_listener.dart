import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';

/// Shows a password-reset step's [PasswordResetState.notice] — the "قريباً" of
/// a step the backend cannot do yet — in a snackbar, once each time it is set.
class PasswordResetNoticeListener extends StatelessWidget {
  final Widget child;

  const PasswordResetNoticeListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) => current.notice != null && current.notice != previous.notice,
      listener: (context, state) => AppSnackbar.show(context, state.notice!),
      child: child,
    );
  }
}
