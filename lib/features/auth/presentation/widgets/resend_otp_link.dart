import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_auth_cubit.dart';
import '../cubit/patient_auth_state.dart';
import 'resend_code_link.dart';

/// The resend link under the patient's OTP boxes: a [ResendCodeLink] that asks
/// [PatientAuthCubit] to send the code again.
class ResendOtpLink extends StatelessWidget {
  const ResendOtpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientAuthCubit, PatientAuthState>(
      buildWhen: (previous, current) => previous.isSendingOtp != current.isSendingOtp,
      builder: (context, state) {
        return ResendCodeLink(
          isSending: state.isSendingOtp,
          onResend: () async {
            final cubit = context.read<PatientAuthCubit>();
            await cubit.sendOtp();
            return cubit.state.errorMessage == null;
          },
        );
      },
    );
  }
}
