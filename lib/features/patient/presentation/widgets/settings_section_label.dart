import 'package:flutter/material.dart';

import '../../../../core/theming/app_text_styles.dart';

/// A group title on the account-settings screen ("التفضيلات").
class SettingsSectionLabel extends StatelessWidget {
  final String text;

  const SettingsSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.right, style: AppTextStyles.settingsSectionLabel);
  }
}
