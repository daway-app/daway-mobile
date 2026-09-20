import 'package:flutter/material.dart';

abstract class AppColors {
// Brand Logo & UI Palette
  static const Color mainTeal = Color(0xFF1C72A6);
  static const Color primaryTeal = Color(0xFF0B8FAC);
  static const Color lightTeal = Color(0xFF7BC1B7);

  // General App Colors
  static const Color scaffoldBackground = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color grey = Color(0xFF757575);
  static const Color greyText = Color(0xFF3E484C);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFF6FAFC);

  // Onboarding Screen
  static const Color  onboardingText = Color(0xFF0D2538);

  // Account Type Screen
  static const Color patientIconBackground = Color(0xFFA6EDE2);
  static const Color pharmacyIconBackground = Color(0xFFB3EBFF);
  static const Color continueButtonBackground = Color(0xFF7BAFBB);
  static const Color cardChevron = Color(0xFFBDC8CD);

  // Account Option Cards
  static const Color cardBorder = Color(0xFFDCE6E9);
  static const Color iconBlueBorder = Color(0xFFB9DDED);
  static const Color accountIconBg = Color(0xA3F0F7FB);
  static const Color permissionIconBg = Color(0xFFF0F7FB);
  static const Color selectedBorder = Color(0xFF1B75BC);
  static const Color cardTitleDark = Color(0xFF0F2830);

  // Auth Redesign (account type / login / OTP / create-account)
  static const Color authTextPrimary = onboardingText;
  static const Color authTextMuted = Color(0xFF4A6169);
  static const Color authInputBorder = Color(0xFF98ADB3);
  static const Color authError = Color(0xFFFF0000);

  // Forms & Feedback
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE8A33D);
  static const Color inputFill = Color(0xFFF5F5F5);

  // Patient Home Screen
  static const Color homeChipBackground = Color(0x1AF0F7FB);
}

