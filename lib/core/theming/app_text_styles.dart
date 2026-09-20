import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle get screenTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      );

  static TextStyle get cardTitle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryTeal,
      );

  static TextStyle get accountOptionTitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      );

  static TextStyle get accountTypeSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.greyText,
      );

  static TextStyle get authScreenTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get authScreenSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.authTextMuted,
      );

  /// Row label used by the account-hub menu (e.g. "معلومات الحساب").
  static TextStyle get accountMenuLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.authTextPrimary,
      );

  /// Field-section labels (e.g. "الاسم") and the profile name shown under
  /// the avatar circle on the account-info screen.
  static TextStyle get profileFieldLabel => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: AppColors.authTextPrimary,
      );

  /// Read-only value shown inside a profile field row, next to its edit chip.
  static TextStyle get profileFieldValue => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.authTextPrimary,
      );

  /// Bold section title used by the address cards ("المنزل"/"العمل") and
  /// the "اضافة عنوان" button.
  static TextStyle get addressCardTitle => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        height: 20 / 16,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get authPermissionTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.2,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get authPermissionSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 22.75 / 16,
        letterSpacing: 0,
        color: AppColors.authTextMuted,
      );

  static TextStyle get authFieldLabel => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get authFieldError => TextStyle(
        fontSize: 12.sp,
        color: AppColors.authError,
      );

  static TextStyle get authLinkText => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get authFooterMuted => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: AppColors.authTextPrimary,
      );

  /// Plain wording inside the sign-up consent sentence ("بالضغط على...").
  static TextStyle get authConsentText => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.authTextPrimary,
      );

  /// The "التالي"/"الشروط والأحكام"/"سياسة الخصوصية" spans inside that same
  /// sentence — same size as [authConsentText] but heavier; the two legal
  /// links additionally get an underline where used.
  static TextStyle get authConsentLink => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.authTextPrimary,
      );

  static TextStyle get cardDescription => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.greyText,
      );

  static TextStyle get footerText => TextStyle(
        fontSize: 14.sp,
        color: AppColors.greyText,
      );

  static TextStyle get authTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.mainTeal,
      );

  static TextStyle get authSubtitle => TextStyle(
        fontSize: 14.sp,
        color: AppColors.greyText,
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.mainTeal,
      );

  static TextStyle get helperText => TextStyle(
        fontSize: 12.sp,
        color: AppColors.grey,
      );

  static TextStyle get errorText => TextStyle(
        fontSize: 13.sp,
        color: AppColors.error,
      );

  /// The bold name header on a person's card (patient inquiries, ratings, ...).
  static TextStyle get personName => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      );

  static TextStyle get onboardingTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.onboardingText,
      );

  static TextStyle get onboardingSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.onboardingText,
      );

  static TextStyle get onboardingSkip => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.onboardingText,
      );

  // ---- Patient Home Screen ----

  /// The "أهلاً بك" half of the header greeting — the patient's name after
  /// it uses [homeGreetingName] instead.
  static TextStyle get homeGreetingRegular => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeGreetingName => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeLocationText => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeSearchHint => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle get homeImageSearchTitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeImageSearchSubtitle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.authTextMuted,
      );

  static TextStyle get homeImageSearchButton => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  /// Section headers ("الاقسام"، "الصيدليات").
  static TextStyle get homeSectionTitle => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeSectionChip => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  static TextStyle get homeCategoryLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  static TextStyle get allCategoriesTitle => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.onboardingText,
      );

  static TextStyle get allCategoriesSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: AppColors.onboardingText,
      );

  static TextStyle get homePharmacyCardTitle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  static TextStyle get homePharmacyCardSubtitle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.authTextMuted,
      );

  /// Section headers on the category-medicines screen ("بماذا تشعر"،
  /// "أدوية قد تعالجها") — medium weight, unlike [homeSectionTitle]'s bold.
  static TextStyle get categorySectionTitle => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      );

  static TextStyle get categoryMedicineName => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onboardingText,
      );

  static TextStyle get categoryMedicineSubtitle => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.onboardingText,
      );
}
