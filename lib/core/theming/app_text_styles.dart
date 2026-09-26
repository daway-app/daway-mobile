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

  // ---- Pharmacy Home Screen ----
  //
  // The design's Medium and Bold are the real Tajawal weights, which the
  // theme's regular-only font family cannot draw (see [AppFonts]) — so these
  // ask for them, unlike the older styles above that get a faux bold.

  /// The greeting's bold name ("صيدلية النور") — 24 Bold at 100%.
  static TextStyle get pharmacyGreetingName => AppFonts.tajawal(
        TextStyle(
          fontSize: 24.sp,
          height: 1.0,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// A section title on the pharmacy home ("الطلبات") — 20 Medium.
  static TextStyle get pharmacySectionTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 20.sp,
          color: AppColors.onboardingText,
        ),
        FontWeight.w500,
      );

  /// The "عرض الكل" chip's label beside it — 14 Medium in the primary blue.
  static TextStyle get pharmacySectionAction => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.mainTeal,
        ),
        FontWeight.w500,
      );

  /// The title of a summary card ("إجمالي المنتجات") — 14/19.25 Medium.
  static TextStyle get pharmacySummaryTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 19.25 / 14,
          color: AppColors.onboardingText,
        ),
        FontWeight.w500,
      );

  /// The big figure on a summary card ("120") — 32/44 Bold.
  static TextStyle get pharmacySummaryValue => AppFonts.tajawal(
        TextStyle(
          fontSize: 32.sp,
          height: 44 / 32,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// The "ILS" in front of the monthly-sales figure: Bold at 24, on the
  /// baseline of [pharmacySummaryValue].
  static TextStyle get pharmacySummaryCurrency =>
      pharmacySummaryValue.copyWith(fontSize: 24.sp);

  /// The text of the dashed "add your medicines file" card — 14/140% Bold,
  /// centered.
  static TextStyle get pharmacyAddFileText => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 1.4,
          letterSpacing: 0.2,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// A small stat tile's figure ("45") — Bold 16 at 100%; the colour is the
  /// tile's.
  static TextStyle get pharmacyTileValue => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          height: 1.0,
        ),
        FontWeight.w700,
      );

  /// A small stat tile's caption ("متوفرة") — Bold 10 on a 16px line; the
  /// colour is the tile's.
  static TextStyle get pharmacyTileLabel => AppFonts.tajawal(
        TextStyle(
          fontSize: 10.sp,
          height: 16 / 10,
        ),
        FontWeight.w700,
      );

  /// An order card's "#DW-1021" — Bold 14 on a 20px line.
  static TextStyle get pharmacyOrderNumber => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 20 / 14,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// An order card's relative time ("منذ 5 د") — Regular 12 in the primary
  /// blue.
  static TextStyle get pharmacyOrderTime => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.mainTeal,
      );

  /// One cell of an order card's summary strip ("2 أدوية", the destination) —
  /// Medium 11 on a 16px line; the price cell is [pharmacyOrderPrice].
  static TextStyle get pharmacyOrderSummary => AppFonts.tajawal(
        TextStyle(
          fontSize: 11.sp,
          height: 16 / 11,
          color: AppColors.onboardingText,
        ),
        FontWeight.w500,
      );

  /// The price cell of an order card's summary strip ("80 ₪") — Bold 12.
  static TextStyle get pharmacyOrderPrice => AppFonts.tajawal(
        TextStyle(
          fontSize: 12.sp,
          height: 16 / 12,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// The label of an order card's "عرض الطلب" button — Bold 12 in the primary
  /// blue.
  static TextStyle get pharmacyOrderButton => AppFonts.tajawal(
        TextStyle(
          fontSize: 12.sp,
          color: AppColors.mainTeal,
        ),
        FontWeight.w700,
      );

  /// A bottom-navigation label — Regular 12/16, selected or not (they differ
  /// in colour alone); the colour is the item's.
  static TextStyle get pharmacyNavLabel => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      );

  // ---- Pharmacy Products Screen ----
  //
  // Real Tajawal weights again (see [AppFonts]), as on the pharmacy home.

  /// The page title ("اجمالي المنتجات") — Bold 24 in black.
  static TextStyle get pharmacyPageTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 24.sp,
          height: 1.5,
          color: Colors.black,
        ),
        FontWeight.w700,
      );

  /// The line under the page title — Regular 16 in black.
  static TextStyle get pharmacyPageSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Colors.black,
      );

  /// The search field's hint and what is typed into it — 14 Medium in navy.
  static TextStyle get pharmacySearchText => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.onboardingText,
        ),
        FontWeight.w500,
      );

  /// A filter chip's label — 14/19.5 Medium in the primary blue; the selected
  /// chip's is [pharmacyFilterChipSelected].
  static TextStyle get pharmacyFilterChip => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 19.5 / 14,
          color: AppColors.mainTeal,
        ),
        FontWeight.w500,
      );

  /// The selected filter chip's label — 14/19.5 Bold in white.
  static TextStyle get pharmacyFilterChipSelected => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 19.5 / 14,
          color: Colors.white,
        ),
        FontWeight.w700,
      );

  /// The label of the "أضف منتج جديد" / "تحديث المنتجات" cards — 14/22.5 Medium
  /// in the primary blue.
  static TextStyle get pharmacyActionCardLabel => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 22.5 / 14,
          color: AppColors.mainTeal,
        ),
        FontWeight.w500,
      );

  /// A product card's name — Bold 14 on a 21px line.
  static TextStyle get pharmacyProductName => AppFonts.tajawal(
        TextStyle(
          fontSize: 14.sp,
          height: 21 / 14,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// A product card's active ingredient — Regular 11/16.5 in grey.
  static TextStyle get pharmacyProductIngredient => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        height: 16.5 / 11,
        color: AppColors.productSecondaryText,
      );

  /// A product card's price — Bold 16/19.5 in navy.
  static TextStyle get pharmacyProductPrice => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          height: 19.5 / 16,
          color: AppColors.onboardingText,
        ),
        FontWeight.w700,
      );

  /// A product card's stock badge ("متوفر") — Medium 12 on a 17px line; the
  /// colour is the badge's.
  static TextStyle get pharmacyProductBadge => AppFonts.tajawal(
        TextStyle(
          fontSize: 12.sp,
          height: 17 / 12,
        ),
        FontWeight.w500,
      );

  /// The quantity between a product card's stepper buttons — ExtraBold 15/22.5
  /// in the primary blue.
  static TextStyle get pharmacyProductQuantity => AppFonts.tajawal(
        TextStyle(
          fontSize: 15.sp,
          height: 22.5 / 15,
          color: AppColors.mainTeal,
        ),
        FontWeight.w800,
      );

  // ---- Password Reset Flow ----
  //
  // The four screens of resetting a forgotten password (forgot, code, new
  // password, confirmation) — real Tajawal weights (see [AppFonts]).

  /// A screen's title ("نسيت كلمة المرور ؟") — Bold 24 in navy.
  static TextStyle get authFlowTitle => AppFonts.tajawal(
        TextStyle(
          fontSize: 24.sp,
          height: 1.5,
          color: AppColors.authTextPrimary,
        ),
        FontWeight.w700,
      );

  /// The line or two under the title — Regular 16 in navy.
  static TextStyle get authFlowSubtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.authTextPrimary,
      );

  /// The label over a field ("رقم الهاتف") — Medium 16 in navy.
  static TextStyle get authFlowFieldLabel => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          height: 1.5,
          color: AppColors.authTextPrimary,
        ),
        FontWeight.w500,
      );

  /// A button's label on the flow's screens ("التالي") — Bold 16; the colour
  /// is the button's.
  static TextStyle get authFlowButton => AppFonts.tajawal(
        TextStyle(fontSize: 16.sp),
        FontWeight.w700,
      );

  /// What is typed into one of the flow's fields — 16 in navy.
  static TextStyle get authFlowInput => TextStyle(
        fontSize: 16.sp,
        height: 1.5,
        color: AppColors.authTextPrimary,
      );

  /// "إعادة الإرسال خلال 00:30" under the code boxes — Regular 13; the colour
  /// is the link's.
  static TextStyle get authFlowResend => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      );

  /// The underlined "نسيت كلمة المرور؟" under the login's password field.
  static TextStyle get authForgotPasswordLink => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.authTextPrimary,
        color: AppColors.authTextPrimary,
      );

  /// "تم تحديث كلمة مرورك بنجاح" on the confirmation card — Bold 16 at 100%,
  /// in black.
  static TextStyle get passwordUpdatedMessage => AppFonts.tajawal(
        TextStyle(
          fontSize: 16.sp,
          height: 1.0,
          color: Colors.black,
        ),
        FontWeight.w700,
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
