class OnboardingPage {
  /// Null while the real illustration hasn't been delivered yet — the
  /// presentation layer renders a generic placeholder in that case.
  final String? illustrationAsset;
  final String title;
  final String subtitle;

  const OnboardingPage({
    this.illustrationAsset,
    required this.title,
    required this.subtitle,
  });
}
