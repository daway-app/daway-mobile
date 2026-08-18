import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/usecases/set_onboarding_seen_usecase.dart';
import '../onboarding_content.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleActionPressed() {
    final isLast = _currentIndex == onboardingPages.length - 1;
    if (isLast) {
      getIt<SetOnboardingSeenUseCase>()();
      Navigator.of(context).pushReplacementNamed(Routes.accountTypeScreen);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: onboardingPages.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return OnboardingPageContent(
              page: onboardingPages[index],
              pageCount: onboardingPages.length,
              currentIndex: _currentIndex,
              isLast: index == onboardingPages.length - 1,
              onActionPressed: _handleActionPressed,
            );
          },
        ),
      ),
    );
  }
}
