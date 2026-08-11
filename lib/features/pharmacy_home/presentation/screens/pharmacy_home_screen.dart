import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/cubit/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout_state.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('الصفحة الرئيسية', style: AppTextStyles.screenTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textDark),
            onPressed: () => LogoutConfirmationDialog.show(
              context,
              onConfirm: () => context.read<LogoutCubit>().logout(),
            ),
          ),
        ],
      ),
      body: BlocListener<LogoutCubit, LogoutState>(
        listenWhen: (previous, current) => !previous.isLoggedOut && current.isLoggedOut,
        listener: (context, state) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.accountTypeScreen, (route) => false);
        },
        child: Center(
          child: Text(
            'أهلاً بك، قريباً إدارة الأدوية والمخزون',
            style: AppTextStyles.authSubtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
