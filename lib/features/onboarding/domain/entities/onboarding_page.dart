enum OnboardingIllustrationStyle { circleBadge, bleedCard }

class OnboardingPage {
  final String? illustrationAsset;
  final OnboardingIllustrationStyle illustrationStyle;
  final String backgroundAsset;

  /// Fraction (0.0–1.0) of blank space to leave above [backgroundAsset].
  /// Background art files don't all start their wave curve at the same
  /// height, so this compensates to keep the curve aligned across pages.
  final double backgroundTopInset;
  final String title;
  final String subtitle;

  const OnboardingPage({
    this.illustrationAsset,
    required this.illustrationStyle,
    required this.backgroundAsset,
    this.backgroundTopInset = 0,
    required this.title,
    required this.subtitle,
  });
}
