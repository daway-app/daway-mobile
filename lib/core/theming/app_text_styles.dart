import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

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

  /// Row label used by the account-hub and account-settings cards (e.g.
  /// "معلومات الحساب", "اللغة").
  static TextStyle get accountMenuLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 24 / 14,
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

  // ---- Patient Search Screen ----

  /// "الأكثر بحثاً" section title.
  static TextStyle get searchSectionTitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.onboardingText,
      );

  /// A trending-search row's term text.
  static TextStyle get searchTermText => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.onboardingText,
      );

  // ---- Empty states (orders, favorites, reminders, notifications, addresses) ----

  /// The bold title of an empty-state view ("لا يوجد طلبات") — Tajawal
  /// ExtraBold, the real weight file (see [AppFonts]).
  static TextStyle get emptyStateTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          color: AppColors.onboardingText,
        ),
        FontWeight.w800,
      );

  /// The darker supporting line under an empty-state title.
  static TextStyle get emptyStateSubtitle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

  /// The label of an empty-state view's call-to-action button — pure black,
  /// like the supporting line above it.
  static TextStyle get emptyStateAction => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

  // ---- Patient Orders Screen ----

  /// An order card's pharmacy name.
  static TextStyle get orderCardPharmacyName => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
        color: AppColors.onboardingText,
      );

  /// An order card's "#DW-1021" order number, and a status filter tab's label.
  static TextStyle get orderCardMuted => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.authTextMuted,
      );

  // ---- Patient Notifications Screen ----

  /// A notification's bold title line.
  static TextStyle get notificationTitle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 19.25 / 14,
        color: AppColors.onboardingText,
      );

  /// A notification's message body and its relative time — Gray-500
  /// (#98ADB3) in the design.
  static TextStyle get notificationBody => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 19.5 / 12,
        color: AppColors.authInputBorder,
      );

  /// Small muted caption text — Gray-500 (#98ADB3), 12/16: a notification's
  /// relative time, and the English trade name under an Arabic one.
  static TextStyle get mutedCaption => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.authInputBorder,
      );

  /// The category chip ("الطلبات", "النظام", ...) on a notification.
  static TextStyle get notificationChip => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onboardingText,
      );

  // ---- Patient Favorites Screen ----

  /// A saved-medicine card's Arabic (or, absent that, English) trade name.
  static TextStyle get favoriteCardName => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 16,
        color: AppColors.onboardingText,
      );

  /// "متوفر في N صيدليات" inside a favorite card's availability strip.
  static TextStyle get favoriteCardAvailability => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppColors.onboardingText,
      );

  /// "يبدأ من" label preceding a favorite card's price.
  static TextStyle get favoriteCardPriceLabel => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.grey,
      );

  /// The bold price itself on a favorite card.
  static TextStyle get favoriteCardPrice => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        height: 20 / 14,
        color: AppColors.onboardingText,
      );

  // ---- Account Settings Screen ----

  /// A settings group title ("التفضيلات") — Gray-500 (#98ADB3), bold.
  static TextStyle get settingsSectionLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
        color: AppColors.authInputBorder,
      );

  /// Muted supporting text on the settings screen: a row's current value
  /// ("العربية") and the app version line.
  static TextStyle get settingsMutedText => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.authInputBorder,
      );

  /// The "دواك" wordmark in the settings footer.
  static TextStyle get settingsBrandName => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: AppColors.mainTeal,
      );

  // ---- Bottom sheets (language picker, logout confirmation) ----

  /// The heading of the language picker sheet ("اختر اللغة") — Tajawal
  /// ExtraBold, the real weight file (see [AppFonts]).
  static TextStyle get sheetHeading => AppFonts.tajawal(
        TextStyle(
          fontSize: 18.sp,
          height: 28 / 18,
          color: AppColors.sheetTitleText,
        ),
        FontWeight.w800,
      );

  /// A language option's name ("العربية", "English") — Tajawal ExtraBold, the
  /// real weight file (see [AppFonts]).
  static TextStyle get sheetOptionTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          height: 24 / 16,
          color: AppColors.sheetTitleText,
        ),
        FontWeight.w800,
      );

  /// The small line under a language option's name ("Arabic").
  static TextStyle get sheetOptionSubtitle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.sheetSubtitleText,
      );

  /// The centered title of the logout confirmation sheet ("تسجيل الخروج؟") —
  /// Tajawal ExtraBold, the real weight file (see [AppFonts]).
  static TextStyle get confirmSheetTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 20.sp,
          height: 28 / 20,
          color: AppColors.sheetTitleText,
        ),
        FontWeight.w800,
      );

  /// The explanatory line under the confirmation sheet's title.
  static TextStyle get confirmSheetMessage => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 22.75 / 14,
        color: AppColors.sheetSubtitleText,
      );

  /// The label of a bottom-sheet action button (color set by the button) —
  /// Tajawal ExtraBold, the real weight file (see [AppFonts]).
  static TextStyle get sheetButtonLabel => AppFonts.tajawal(
        TextStyle(fontSize: 16.sp),
        FontWeight.w800,
      );
}
