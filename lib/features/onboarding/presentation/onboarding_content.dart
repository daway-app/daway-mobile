import '../domain/entities/onboarding_page.dart';

const List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/illustration_reminders.svg',
    illustrationStyle: OnboardingIllustrationStyle.circleBadge,
    backgroundAsset: 'assets/images/onboarding/background1.png',
    title: 'اعرف توفر دوائك قبل ما توصل',
    subtitle: 'ابحث عن أي دواء وشوف فورًا الصيدليات القريبة التي توفره لديها',
  ),
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/illustration_location.svg',
    illustrationStyle: OnboardingIllustrationStyle.bleedCard,
    backgroundAsset: 'assets/images/onboarding/image.png',
    backgroundTopInset: 0.16,
    title: 'أقرب صيدلية بلمح البصر',
    subtitle: 'تعرف على الصيدليات والمراكز الصحية القريبة منك على الخريطة بسهولة',
  ),
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/Illustration_3.svg',
    illustrationStyle: OnboardingIllustrationStyle.circleBadge,
    backgroundAsset: 'assets/images/onboarding/background3.png',
    title: 'دوائي، خيارك الأفضل لخدمة صحية أسرع وأسهل',
    subtitle: 'انضم الآن وابدأ رحلتك نحو صحة أفضل مع دوائي',
  ),
];
