import '../domain/entities/onboarding_page.dart';

const List<OnboardingPage> patientOnboardingPages = [
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/onboarding_image1.png',
    title: 'ابحث أو امسح وصفتك',
    subtitle: 'اعثر على أدويتك بطريقة أسهل.',
  ),
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/onboarding_image2.png',
    title: 'قارن الصيدليات',
    subtitle: 'قارن الأسعار والتقييم والمسافة واختر الأنسب لك.',
  ),
  OnboardingPage(
    illustrationAsset: 'assets/images/onboarding/onboarding_image3.png',
    title: 'اطلب من أكثر من صيدلية',
    subtitle: 'اجمع منتجاتك في طلب واحد، حتى لو كانت من صيدليات مختلفة.',
  ),
];

/// Illustrations aren't ready yet from design — [OnboardingPageContent]
/// renders a placeholder box when `illustrationAsset` is null.
const List<OnboardingPage> pharmacyOnboardingPages = [
  OnboardingPage(
    title: 'تحكم بمنتجات صيدليتك',
    subtitle: 'حدّث الأسعار والمخزون وتوفر المنتجات بكل سهولة.',
  ),
  OnboardingPage(
    title: 'استقبل طلباتك بسهولة',
    subtitle: 'استقبل طلبات العملاء وراجع تفاصيلها قبل قبولها أو رفضها.',
  ),
  OnboardingPage(
    title: 'تواصل مباشرة مع عملائك',
    subtitle: 'أجب عن استفسارات العملاء وتابع محادثاتهم من مكان واحد.',
  ),
];
